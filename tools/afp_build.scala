/* Author: Lars Hupel and Fabian Huch, TU Muenchen

Unified AFP CI integration.
 */
package afp


import isabelle.*
import isabelle.CI_Build.{hg_id, print_section, Build_Config, Failed, Job, Profile, Result, Status}

import afp.Metadata.{Email, Entry}

import java.time.{Instant, ZoneId}
import java.time.format.DateTimeFormatter
import java.util.{Map => JMap, Properties => JProperties}

import javax.mail.internet.{InternetAddress, MimeMessage}
import javax.mail.{Authenticator, Message, MessagingException, PasswordAuthentication, Transport, Session => JSession}


object AFP_Build {
  /* mailing */

  case class Mail(subject: String, recipients: List[String], text: String) {
    def send(): Unit = {
      val user = System.getProperty("mail.smtp.user")
      val sender = System.getProperty("mail.smtp.from")
      val password = System.getProperty("mail.smtp.password")

      System.setProperty("mail.smtp.ssl.protocols", "TLSv1.2")

      val authenticator = new Authenticator() {
        override def getPasswordAuthentication =
          new PasswordAuthentication(user, password)
      }

      val session = JSession.getDefaultInstance(System.getProperties, authenticator)
      val message = new MimeMessage(session)
      message.setFrom(new InternetAddress("ci@isabelle.systems", "Isabelle/Jenkins"))
      message.setSender(new InternetAddress(sender))
      message.setSubject(subject)
      message.setText(text, "UTF-8")
      message.setSentDate(new java.util.Date())

      recipients.foreach { recipient =>
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipient))
      }

      try {
        Transport.send(message)
      } catch {
        case ex: MessagingException => println(s"Sending mail failed: ${ex.getMessage}")
      }
    }
  }

  object Mail {
    def apply(subject: String, recipients: List[String], text: String) =
      new Mail(subject, recipients, text)

    def failed_subject(name: Entry.Name): String = s"Build of AFP entry $name failed"

    def failed_text(session_name: String, entry: Entry.Name, isabelle_id: String,
      afp_id: String, result: Process_Result): String = s"""
The build for the session
  $session_name,
belonging to the AFP entry
  $entry
failed.

You are receiving this mail because you are the maintainer of that AFP
entry.

The following information might help you with resolving the problem.

Build log:    ${Isabelle_System.getenv("BUILD_URL")}
Isabelle ID:  $isabelle_id
AFP ID:       $afp_id
Timeout?      ${result.timeout}
Exit code:    ${result.rc}

Last 50 lines from stdout (if available):

${result.out_lines.takeRight(50).mkString("\n")}

Last 50 lines from stderr (if available):

${result.err_lines.takeRight(50).mkString("\n")}
"""
  }


  /* metadata tooling */

  case class Metadata_Tools private(structure: AFP_Structure, entries: Map[Entry.Name, Entry]) {

    def maintainers(name: Entry.Name): List[Email] = {
      entries.get(name) match {
        case None => Nil
        case Some(entry) => entry.notifies
      }
    }

    val sessions: Map[Entry.Name, List[String]] =
      entries.values.map(entry =>
        entry.name -> structure.entry_sessions(entry.name).map(_.name)).toMap

    def session_entry(session_name: String): Option[Entry.Name] = {
      val entry = sessions.find { case (_, sessions) => sessions.contains(session_name) }
      entry.map { case (name, _) => name }
    }

    def by_entry(sessions: List[String]): Map[Option[Entry.Name], List[String]] =
      sessions.groupBy(session_entry)

    def notify(name: Entry.Name, subject: String, text: String): Boolean = {
      val recipients = entries.get(name).map(_.notifies).getOrElse(Nil)
      if (recipients.nonEmpty) Mail(subject, recipients.map(_.address), text).send()
      recipients.nonEmpty
    }
  }

  object Metadata_Tools {
    def apply(structure: AFP_Structure, entries: List[Entry]): Metadata_Tools =
      new Metadata_Tools(structure, entries.map(entry => entry.name -> entry).toMap)
    def load(afp: AFP_Structure): Metadata_Tools = Metadata_Tools(afp, afp.load())
  }


  /* utilities */

  def status_as_json(isabelle_id: String, afp_id: String, start_time: String,
    status: Map[Option[String], Status]): String = {
    val entries_strings = status.collect {
      case (Some(entry), status) =>
        s"""{"entry": "$entry", "status": "${status.str}"}"""
    }

    val entries_string = entries_strings.mkString("[", ",\n", "]")

    s"""
      {"build_data":
        {"isabelle_id": "$isabelle_id",
         "afp_id": "$afp_id",
         "time": "$start_time",
         "url": "${Isabelle_System.getenv("BUILD_URL")}",
         "job": "${Isabelle_System.getenv("JOB_NAME")}"
        },
       "entries":
         $entries_string
      }
    """
  }

  def status_as_html(status: Map[Option[String], Status]): String = {
    val entries_strings = status.collect {
      case (None, Failed) =>
        s"<li>Distribution</li>"
      case (Some(entry), Failed) =>
        s"""<li><a href="https://devel.isa-afp.org/entries/$entry.html">$entry</a></li>"""
    }

    if (entries_strings.isEmpty)
      ""
    else
      entries_strings.mkString("Failed entries: <ul>", "\n", "</ul>")
  }


  /* ci build jobs */

  val afp =
    Job("afp", "builds the AFP, without slow sessions", Profile.from_host,
      {
        val afp = AFP_Structure()

        val status_file = Path.explode("$ISABELLE_HOME/status.json").file
        val deps_file = Path.explode("$ISABELLE_HOME/dependencies.json").file

        def pre_hook(): Result = {
          println(s"AFP id ${ afp.hg_id }")
          if (status_file.exists())
            status_file.delete()
          Result.ok
        }

        def post_hook(results: Build.Results, start_time: Time): Result = {
          print_section("DEPENDENCIES")
          println("Generating dependencies file ...")
          val result = Isabelle_System.bash("isabelle afp_dependencies")
          result.check
          println("Writing dependencies file ...")
          File.write(deps_file, result.out)
          print_section("COMPLETED")
          Result.ok
        }

        Build_Config(
          clean = false, include = List(afp.thys_dir), pre_hook = pre_hook,
          post_hook = post_hook, selection = Sessions.Selection(
            session_groups = List("AFP"),
            exclude_session_groups = List("slow")))
      })
  
  val all =
    Job("all", "builds Isabelle + AFP (without slow)", Profile.from_host,
      {
        val afp = AFP_Structure()
        val isabelle_home = Path.explode(Isabelle_System.getenv_strict("ISABELLE_HOME"))
        val isabelle_id = hg_id(isabelle_home)

        val status_file = Path.explode("$ISABELLE_HOME/status.json").file
        val report_file = Path.explode("$ISABELLE_HOME/report.html").file
        val deps_file = Path.explode("$ISABELLE_HOME/dependencies.json").file

        def can_send_mails = System.getProperties.containsKey("mail.smtp.host")

        def pre_hook(): Result = {
          println(s"AFP id ${ afp.hg_id }")
          if (status_file.exists())
            status_file.delete()
          if (report_file.exists())
            report_file.delete()

          File.write(report_file, "")

          if (!can_send_mails) {
            println(s"Mail configuration not found.")
            Result.error
          } else {
            Result.ok
          }
        }

        def post_hook(results: Build.Results, start_time: Time): Result = {
          print_section("DEPENDENCIES")
          println("Generating dependencies file ...")
          val result = Isabelle_System.bash("isabelle afp_dependencies")
          result.check
          println("Writing dependencies file ...")
          File.write(deps_file, result.out)

          val metadata = Metadata_Tools.load(afp)

          val status = metadata.by_entry(results.sessions.toList).view.mapValues { sessions =>
            Status.merge(sessions.map(Status.from_results(results, _)))
          }.toMap

          print_section("REPORT")
          println("Writing report file ...")
          File.write(report_file, status_as_html(status))

          print_section("SITEGEN")
          println("Writing status file ...")
          val formatted_time =
            start_time.instant.atZone(ZoneId.systemDefault)
              .format(DateTimeFormatter.RFC_1123_DATE_TIME)
          File.write(status_file, status_as_json(isabelle_id, afp.hg_id, formatted_time, status))
          println("Running sitegen ...")

          val script = afp.base_dir + Path.explode("admin/sitegen-devel")
          val sitegen_cmd =
            Bash.strings(List(script.file.toString, status_file.toString, deps_file.toString))

          val sitegen_res =
            Isabelle_System.bash(sitegen_cmd, progress_stdout = println, progress_stderr = println)
          if (!sitegen_res.ok) {
            println("sitegen failed")
          }

          if (!results.ok) {
            print_section("NOTIFICATIONS")
            for (session_name <- results.sessions) {
              val result = results(session_name)
              if (!result.ok && !results.cancelled(session_name) && can_send_mails) {
                metadata.session_entry(session_name).foreach { entry =>
                  val subject = Mail.failed_subject(entry)
                  val text = Mail.failed_text(session_name, entry, isabelle_id, afp.hg_id, result)
                  val notified = metadata.notify(entry, subject, text)
                  if (!notified) println(s"Entry $entry: WARNING no maintainers specified")
                }
              }
            }
          }

          print_section("COMPLETED")
          Result(sitegen_res.rc)
        }

        Build_Config(
          clean = false, include = List(afp.thys_dir), pre_hook = pre_hook,
          post_hook = post_hook, selection = Sessions.Selection(
            all_sessions = true,
            exclude_session_groups = List("slow")))
      })
  
  val mac =
    Job("mac", "builds the AFP (without some sessions) on Mac Os",
      Profile.from_host.copy(threads = 8, jobs = 1),
      {
        val afp = AFP_Structure()

        def pre_hook(): Result = {
          println(s"Build for AFP id ${ afp.hg_id }")
          Result.ok
        }

        Build_Config(
          include = List(afp.thys_dir), pre_hook = pre_hook, selection =
            Sessions.Selection(
              all_sessions = true,
              exclude_sessions = List("HOL-Proofs", "HOL-ODE-Numerics", "Linear_Programming", "HOL-Nominal-Examples", "HOL-Analysis"),
              exclude_session_groups = List("slow")))
      })
  
  val slow =
    Job("slow", "builds the AFP slow sessions", Profile.from_host.copy(threads = 8, jobs = 1),
      {
        val afp = AFP_Structure()

        def pre_hook(): Result = {
          println(s"Build for AFP id ${ afp.hg_id }")
          Result.ok
        }

        Build_Config(
          include = List(afp.thys_dir), pre_hook = pre_hook,
          selection = Sessions.Selection(session_groups = List("slow")))
      })

  val testboard =
    Job("testboard", "builds the AFP testboard", Profile.from_host,
      {
        val afp = AFP_Structure()
        val report_file = Path.explode("$ISABELLE_HOME/report.html").file

        def pre_hook(): Result = {
          println(s"AFP id ${ afp.hg_id }")
          if (report_file.exists())
            report_file.delete()

          File.write(report_file, "")
          Result.ok
        }

        def post_hook(results: Build.Results, start_time: Time): Result = {
          val metadata = Metadata_Tools.load(afp)

          val status = metadata.by_entry(results.sessions.toList).view.mapValues { sessions =>
            Status.merge(sessions.map(Status.from_results(results, _)))
          }.toMap

          print_section("REPORT")
          println("Writing report file ...")
          File.write(report_file, status_as_html(status))
          print_section("COMPLETED")
          Result.ok
        }

        Build_Config(
          clean = false, include = List(afp.thys_dir), pre_hook = pre_hook,
          post_hook = post_hook, selection =
            Sessions.Selection(
              all_sessions = true,
              exclude_session_groups = List("slow")))
      })
}

class CI_Builds extends Isabelle_CI_Builds(
  AFP_Build.afp,
  AFP_Build.all,
  AFP_Build.slow,
  AFP_Build.mac,
  AFP_Build.testboard)

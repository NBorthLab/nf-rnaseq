class Util {

    static def processVersionsFromYaml(yaml_file) {
        def yaml = new org.yaml.snakeyaml.Yaml()
        def versions = yaml.load(yaml_file).collectEntries { k, v -> [k.tokenize(":")[-1], v] }
        return yaml.dumpAsMap(versions).trim()
    }

    static def formatNextflowVersion(version) {
        return """
        Workflow:
          Nextflow: ${version}
        """.stripIndent().trim()
    }

    static def sendNotification(success, ntfy_url) {
        def message = "Workflow completed: $success"

        def con = new URL(ntfy_url).openConnection() as HttpURLConnection
        con.setRequestMethod("POST")
        con.setDoOutput(true)

        def output = con.getOutputStream()
        output.write(message.getBytes("UTF-8"))
        output.flush()
        output.close()

        print("Notification sent ($ntfy_url): $con.responseCode")
    }
}

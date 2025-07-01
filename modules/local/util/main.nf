process GUNZIP {

    input:
    path file

    output:
    path "${file.baseName}"

    script:
    """
    gunzip -c $file > ${file.baseName}
    """
}


process GTF2BED {

    container "https://depot.galaxyproject.org/singularity/bedops:2.4.40--h9f5acd7_0"

    input:
    path gtf

    output:
    path "*.bed"

    script:
    """
    gtf2bed < $gtf > ${gtf.baseName}.bed
    """
}


def processVersionsFromYaml(yaml_file) {
    def yaml = new org.yaml.snakeyaml.Yaml()
    def versions = yaml.load(yaml_file).collectEntries { k, v -> [k.tokenize(":")[-1], v] }
    return yaml.dumpAsMap(versions).trim()
}

def formatNextflowVersion() {
    return """
    Workflow:
        Nextflow: ${nextflow.version}
        ${workflow.manifest.name}: ${workflow.manifest.version}
    """.stripIndent().trim()
}

def sendNotification(success, ntfy_url) {
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

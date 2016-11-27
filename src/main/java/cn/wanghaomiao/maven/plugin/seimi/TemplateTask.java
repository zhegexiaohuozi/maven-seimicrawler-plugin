package cn.wanghaomiao.maven.plugin.seimi;


import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.maven.plugin.logging.Log;

import java.io.File;
import java.net.URL;

/**
 * @author github.com/zhegexiaohuozi [seimimaster@gmail.com]
 * @since 2015/12/28.
 */
public class TemplateTask {
    private File outDir;
    private Log log;

    public TemplateTask(File outDir, Log log) {
        this.outDir = outDir;
        this.log = log;
    }

    public void createBinFile() {
        try {
            File bin = new File(outDir, "bin");
            bin.mkdir();
            createFile(bin, "seimi.cfg");
            createFile(bin, "run.bat");
            createFile(bin, "run.sh");

        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

    public void createFile(File dir, String fileName) {
        try {
            URL resource = this.getClass().getClassLoader().getResource("template/" + fileName);
            assert resource != null;
            String content = IOUtils.toString(resource.openStream());
            content = content.replaceAll("\r","");
            FileUtils.writeStringToFile(new File(dir, fileName),content);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }
}

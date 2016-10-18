package cn.wanghaomiao.maven.plugin.seimi;


import org.apache.commons.io.FileUtils;
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
            createFile(bin, "seimi.vmoptions");
            createFile(bin, "seimi.cfg");
            createFile(bin, "run.bat");
            createFile(bin, "run.sh");

        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

    public void createFile(File dir, String fileName) {
        try {
            URL resourc = this.getClass().getClassLoader().getResource("template/" + fileName);
            assert resourc != null;
            FileUtils.copyURLToFile(resourc, new File(dir, fileName));
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }
}

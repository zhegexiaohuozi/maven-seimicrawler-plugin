package cn.wanghaomiao.maven.plugin.seimi;


import freemarker.cache.ClassTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;
import org.apache.maven.plugin.logging.Log;

import java.io.File;
import java.io.FileWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

/**
 * @author github.com/zhegexiaohuozi [seimimaster@gmail.com]
 * @since 2015/12/28.
 */
public class TemplateTask {
    private File outDir;
    private Configuration cfg;
    private Log log;

    public TemplateTask(File outDir, Log log) {
        this.outDir = outDir;
        this.log = log;
        this.cfg = new Configuration(Configuration.VERSION_2_3_22);
        ClassTemplateLoader loader = new ClassTemplateLoader(TemplateTask.class.getClassLoader(), "template");
        cfg.setTemplateLoader(loader);
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
    }

    public void genBinFile() {
        try {
            File bin = new File(outDir, "bin");
            bin.mkdir();
            Map<String, Object> ctx = new HashMap<String, Object>();
            Template templateBat = cfg.getTemplate("run.bat.ftl");
            Writer batBinFile = new FileWriter(new File(bin, "run.bat"));
            templateBat.process(ctx, batBinFile);
            batBinFile.flush();
            batBinFile.close();

            Template templateSh = cfg.getTemplate("run.sh.ftl");
            StringWriter stringWriter = new StringWriter();
            FileWriter shBinFile = new FileWriter(new File(bin, "run.sh"));
            templateSh.process(ctx, stringWriter);
            shBinFile.write(stringWriter.toString().replaceAll("\r",""));
            shBinFile.flush();
            shBinFile.close();

        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }
}

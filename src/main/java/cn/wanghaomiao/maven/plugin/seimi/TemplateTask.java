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

    public void createBinFile() {
        try {
            File bin = new File(outDir, "bin");
            bin.mkdir();
            Map<String, Object> ctx = new HashMap<String, Object>();

            createFile(ctx,bin,"seimi.vmoptions");
            createFile(ctx,bin,"seimi.cfg");
            createFile(ctx,bin,"run.bat");

            Template templateSh = cfg.getTemplate("run.sh");
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

    public void createFile(Map<String,Object> ctx,File dir,String fileName){
        try {
            Template templateBat = cfg.getTemplate(fileName);
            Writer binFile = new FileWriter(new File(dir, fileName));
            templateBat.process(ctx, binFile);
            binFile.flush();
            binFile.close();
        }catch (Exception e){
            log.error(e.getMessage(),e);
        }
    }
}

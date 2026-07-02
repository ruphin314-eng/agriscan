package apash.coding.sa.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${upload.dir:uploads/photos}")
    private String uploadDir;

    // ── Servir les images uploadées via /uploads/photos/** ──
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry
            .addResourceHandler("/uploads/photos/**")
            .addResourceLocations("file:" + uploadDir + "/");
    }
}

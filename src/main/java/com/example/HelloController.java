package com.example;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;

/**
 * Created by ahmetatalay on 14/01/17.
 */

@RestController
public class HelloController {

    @RequestMapping("/")
    public String index() {
      String bodyContent = "<h1>Hello World</h1>";
      
      try {
        File f = new File("/opt/helloworldjavaapp/BUILD_NUMBER");
        if(f.exists() && !f.isDirectory()) { 
          BufferedReader brTest = new BufferedReader(new FileReader(f));
          String buildNumber = brTest.readLine();
          bodyContent+= "<hr><i>Build Number: "+buildNumber+"</i>";
        }        
      } catch (Exception e) {
        e.printStackTrace();
      }
        
      return bodyContent;
    }

}

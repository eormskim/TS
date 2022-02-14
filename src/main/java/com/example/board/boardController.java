package com.example.board;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class boardController {

    @GetMapping("/")
    public String list(){
        return "board/list";
    }

    @GetMapping("/detail")
    public String detail(){
        return "board/detail";
    }

    @GetMapping("/edit")
    public String edit(){
        return "board/edit";
    }
}

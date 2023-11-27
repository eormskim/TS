package com.example.board.controller;

import com.example.board.entity.Board;
import com.example.board.repository.BoardRepository;
import com.example.board.service.BoardService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;


@Controller
@Slf4j
public class BoardController {

    @Autowired
    private BoardService boardService;

    @Autowired
    private BoardRepository boardRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/")
    public String list(Model model
            , @RequestParam(required = false, defaultValue = "0", value = "page") int page
            , @RequestParam(required = false, defaultValue = "", value = "searchVal") String searchVal) {

        //불러올 페이지의 데이터 1페이지는 0부터 시작
        Page<Board> listPage = boardService.list(page, searchVal);

        //총페이지수
        int totalPage = listPage.getTotalPages();

        model.addAttribute("board", listPage.getContent());
        model.addAttribute("totalPage", totalPage);
        model.addAttribute("pageNo", page);
        model.addAttribute("number", listPage.getNumber());
        model.addAttribute("resultDataTotal", listPage.getTotalElements());
        model.addAttribute("size", listPage.getSize());
        model.addAttribute("searchVal", searchVal);

        return "board/list";
    }

    //게시판 상세
    @GetMapping("/board/detail/{boardIdx}")
    public String detail(@PathVariable Long boardIdx, Model model) {
        log.info("boardIdx={}", boardIdx);
        Board boardDetail = boardService.getDetail(boardIdx);
        log.info("boardDetail={}", boardDetail);
        model.addAttribute("board", boardDetail);
        return "board/detail";
    }

    //수정
    @ResponseBody
    @PostMapping("/board/update")
    public Long updateBoard(@RequestBody Board board) {
        log.info("params={}", board);

        boolean isSuccess = boardService.getIsSuccess(board);
        if (isSuccess) {
            return boardService.saveBoard(board);
        } else {
            return 0L;
        }
    }

    //삭제
    @ResponseBody
    @PostMapping("/board/delete")
    public long deleteBoard(@RequestBody Board board) {
        log.info("params={}", board);
        boolean isSuccess = boardService.getIsSuccess(board);
        if (isSuccess) {
            return boardService.deleteBoard(board.getBoardIdx());
        } else {
            return 0L;
        }
    }

    @GetMapping("/board/edit")
    public String edit() {
        return "board/edit";
    }

    //게시판 저장
    @ResponseBody
    @PostMapping("/board/save")
    public Board editBoard(@RequestBody Board board) {
        log.info("params={}", board);

        boardService.saveBoard(board);
        return board;
    }

    @GetMapping("/ts")
    public String tsPage() {
        return "ts/test";
    }
}

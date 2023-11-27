package com.example.board.service;

import com.example.board.entity.Board;
import com.example.board.repository.BoardRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class BoardService {
    @Autowired
    private BoardRepository boardRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    //게시판 목록
    public Page<Board> list(int page, String searchVal){
        if(searchVal.isEmpty()){
            return boardRepository.findAllByDelYn(PageRequest.of(page, 10, Sort.by(Sort.Direction.DESC, "boardIdx")),"N");
        }else{
            return boardRepository.findAllByBoardTitleContainingIgnoreCaseAndDelYn(PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "boardIdx")), searchVal, "N");
        }
    }

    //게시판 저장
    public Long saveBoard(Board board){
        board.setPassword(passwordEncoder.encode(board.getPassword()));
        return boardRepository.save(board).getBoardIdx();
    }

    //게시판 상세
    public Board getDetail(Long boardIdx){
        Optional<Board> optional = boardRepository.findById(boardIdx);
        if(optional.isPresent()){
            Board board = optional.get();
            board.setViewCount(board.getViewCount()+1);
            boardRepository.save(board);
            return board;
        }else{
            throw new NullPointerException();
        }
    }

    //게시글 삭제
    public Long deleteBoard(Long boardIdx){
        Board board = boardRepository.findAllByBoardIdx(boardIdx);
        board.setDelYn("Y");
        return boardRepository.save(board).getBoardIdx();
    }

    public boolean getIsSuccess(Board board){
        Board getData = boardRepository.findAllByBoardIdx(board.getBoardIdx());
        boolean isSuccess = passwordEncoder.matches(board.getPassword(),getData.getPassword());

        return isSuccess;
    }

}

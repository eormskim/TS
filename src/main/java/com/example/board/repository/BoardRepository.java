package com.example.board.repository;

import com.example.board.entity.Board;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BoardRepository extends JpaRepository<Board, Long> {
    //delYn 조건
    Page<Board> findAllByDelYn(Pageable pageable, String delYn);

    //delYn 조건, boardTitle like 조건
    Page<Board> findAllByBoardTitleContainingIgnoreCaseAndDelYn(Pageable pageable, String boardTitle, String delYn);

    Board findAllByBoardIdx(Long boardIdx);

}

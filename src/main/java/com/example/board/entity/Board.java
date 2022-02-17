package com.example.board.entity;

import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
public class Board {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long boardIdx;

    @Column(columnDefinition = "varchar(100) not null comment '타이틀'")
    private String boardTitle;

    @Column(columnDefinition = "TEXT not null comment '내용'")
    private String boardContent;

    @Column(columnDefinition = "varchar(45) not null comment '등록자'")
    private String regId;

    @Column(columnDefinition = "varchar(100) not null comment '비밀번호'")
    private String password;

    private int viewCount;

    @Column(columnDefinition = "char(1) not null default 'N' comment '삭제yn'")
    private String delYn;

    //insert시에 현재시간을 읽어서 저장
    @CreationTimestamp
    private LocalDateTime regDate;

    //update시에 현재시간을 읽어서 저장
    @UpdateTimestamp
    private LocalDateTime uptDate;
}

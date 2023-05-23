<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="util" uri="/WEB-INF/tld/utility.tld" %>
<%@ page import="java.util.List,java.util.ArrayList"%>
<%@ page import="com.saltware.enview.Enview"%>
<%@ page import="com.saltware.enview.om.page.Page"%>
<%@ page import="com.saltware.enview.sso.EnviewSSOManager"%>
<%@ page import="com.saltware.enview.components.dao.ConnectionContext"%>
<%@ page import="com.saltware.enview.components.dao.ConnectionContextForRdbms"%>
<%@ page import="com.saltware.enview.components.dao.DAOFactory"%>
<%@ page import="com.saltware.enview.codebase.CodeBundle"%>
<%@ page import="com.saltware.enview.code.EnviewCodeManager"%>
<%@ page import="com.saltware.enboard.security.SecurityMngr"%>
<%@ page import="com.saltware.enboard.integrate.DefaultBltnExtnMapper"%>
<%@ page import="com.saltware.enboard.integrate.DefaultBltnExtnVO"%>
<%@ page import="com.saltware.enboard.dao.AdminDAO"%>
<%@ page import="com.saltware.enboard.form.AdminCateForm"%>
<%@ page import="com.saltware.enboard.vo.BoardVO"%>
<%@ page import="com.saltware.enboard.vo.BoardSttVO"%>
<%@ page import="com.saltware.enface.enboard.vo.BoardMenuVo"%>
<%@ page import="com.saltware.enface.enboard.service.BoardMenuManager"%>
<%@ page import="com.saltware.enface.util.StringUtil"%>
<%
    String langKnd = (String) pageContext.getSession().getAttribute("langKnd");
    String cPath   = request.getContextPath();
    String userId  = EnviewSSOManager.getUserId(request, response);

    request.setAttribute("userId" , userId);
    request.setAttribute("langKnd", langKnd);
    request.setAttribute("cPath"  , cPath);

    BoardSttVO boardSttVO = (BoardSttVO) request.getAttribute("boardSttVO");
    BoardVO boardVO = (BoardVO) request.getAttribute("boardVO");

    CodeBundle enviewCodeBundle = EnviewCodeManager.getInstance().getBundle(langKnd);
    List srchTypeList = (List) enviewCodeBundle.getCodes("PT", "GNU011", 1, true);
    request.setAttribute("srchTypeList"  , srchTypeList);
%>

<%--BEGIN::현재 게시판이 속한 카테고리에 속한(동일레벨) 게시판들의 목록을 뿌리는 예제--%>
<%
    ConnectionContext connCtxt = null;
    try {
        connCtxt = new ConnectionContextForRdbms (true);

        BoardVO brdVO = (BoardVO)request.getAttribute ("boardVO");
        AdminDAO admDAO = (AdminDAO)DAOFactory.getInst().getDAO (AdminDAO.DAO_NAME_PREFIX);

        String cateId = admDAO.getCateOfBoard (brdVO.getBoardId(), connCtxt);
        List boardList = new ArrayList();
        AdminCateForm acForm = new AdminCateForm();
        acForm.setCateId (cateId);
        boardList.addAll (admDAO.getCateBoard (acForm, null, true, connCtxt));

        // Q&A 전체 카테고리 and 처리해야 할 카테고리
        List<String> qnaCateList = null;
        qnaCateList = (List<String>)pageContext.getSession().getAttribute("accessibleCateList");
        String menuType = request.getParameter("menuType");
        if(menuType == null){
            menuType = (String)request.getSession(false).getAttribute("qnaMenuType");
        }
        if("ADM".equals(menuType)){
            qnaCateList = (List<String>)pageContext.getSession().getAttribute("replyableCateList");
        }

        com.saltware.enboard.cache.CacheMngr ebCacheMngr = (com.saltware.enboard.cache.CacheMngr)Enview.getComponentManager().getComponent ("com.saltware.enboard.cache.CacheMngr");
        List curCateBoardList = new ArrayList();
        for (int i=0; i<boardList.size(); i++) {
            for(int j=0; j<qnaCateList.size(); j++){
                if( ((String)boardList.get(i)).equals((String)qnaCateList.get(j)) ){
                    curCateBoardList.add (ebCacheMngr.getBoard ((String)boardList.get(i), SecurityMngr.getLocale (request)));
                }
            }
        }
        request.setAttribute ("curBoardList", curCateBoardList);
        request.getSession(false).setAttribute ("qnaMenuType", menuType);

    } catch (Exception e) {
        e.printStackTrace();
        if (connCtxt != null) connCtxt.rollback();
        // Ignore...
    } finally {
        if (connCtxt != null) connCtxt.release();
    }
%>
<script type="text/javascript">

    //목록이 없을 경우 게시판 th 넓이 설정
    function thWidthSize(){
        var winWidth = $(window).innerWidth(),
            thTitWidth = $('.list_none .thead .title').outerWidth(),
            thIdx = $('.list_none .thead .th:not(.title)').length,
            thWidth = (winWidth-thTitWidth)/thIdx + 'px';

        if(winWidth < 957){
            thIdx = 1;
            thWidth = (winWidth-thTitWidth)/thIdx + 'px';
        }

        $('.list_none .thead .th:not(.title)').css('width', thWidth);
    }

    // Q&A 카테고리 변경 시 해당 게시판으로 이동
    function moveTargetBoard(boardId){
        location.href = "${cPath}/board/list.brd?boardId="+boardId+"&menuType=${qnaMenuType}";
    }

    $(function(){
        thWidthSize();
        $(window).resize(function(){
            thWidthSize();
        });
    });
</script>
<link rel="stylesheet" type="text/css" media="screen, projection" href="${cPath}/gnu/css/board.css"/>

<c:set var="loginInfo" value="${secPmsnVO.loginInfo}" />
<c:set var="colspanSize" value="0" />

<!-- <div class="board"> -->
<!-- <body id="iframe"> -->
<form id="setSrch" name="setSrch" method="post" onsubmit="return ebList.srchBulletin();">
    <fieldset class="search_wrap cf">
        <c:if test="${boardSttVO.cmpBrdId ne 'gnu_board_000_my'}">
            <!--BEGIN:: QnA게시판 카테고리에 속한 게시판 목록 -->
            <select name="boardSel" class="boardSel" onchange="javascript:moveTargetBoard(this.value);" title="Q&A Category">
                <c:forEach items="${curBoardList}" var="curBoard">
                    <c:if test="${!empty curBoard.boardId}">
                        <option value="<c:out value='${curBoard.boardId}'/>" <c:if test="${curBoard.boardId eq boardVO.boardId}">selected</c:if> title="${curBoard.boardNm}"><c:out value="${curBoard.boardNm}"/></option>
                    </c:if>
                </c:forEach>
            </select>
            <!--END:: QnA게시판 카테고리에 속한 게시판 목록 -->
        </c:if>
        <!--BEGIN:: QnA게시판 답변상태 -->
        <select name="cateSel" onchange="ebList.cateList(this.value)" title="<util:message key='ct.label.ttl.prog.ans'/>">
            <option value="-1" title="<util:message key='ct.label.ttl.all'/>"><util:message key="ct.label.ttl.all"/></option>
            <option value="W" title="<util:message key='ct.label.ttl.wait'/>" <c:if test="${boardSttVO.bltnCateId eq 'W'}">selected</c:if>><util:message key="ct.label.ttl.wait"/></option>
            <option value="P" title="<util:message key='ct.label.ttl.proc'/>" <c:if test="${boardSttVO.bltnCateId eq 'P'}">selected</c:if>><util:message key="ct.label.ttl.proc"/></option>
            <option value="C" title="<util:message key='ct.label.ttl.comp'/>" <c:if test="${boardSttVO.bltnCateId eq 'C'}">selected</c:if>><util:message key="ct.label.ttl.comp"/></option>
        </select>
        <!--END:: QnA게시판 답변상태 -->

        <select id="sel01" name="srchType" title="<util:message key='ct.label.ttl.srchableItem'/>">
            <c:forEach items="${srchTypeList}" var="list">
                <option value="<c:out value="${list.code}"/>" <c:if test="${boardSttVO.srchType == list.code}">selected"</c:if> title="${list.codeName}"><c:out value="${list.codeName}"/></option>
            </c:forEach>
        </select>
        <label for="txt01"></label>
        <input type="text" id="srchKey" placeholder="<util:message key='ct.msg.info.inptSrchWrd'/>" title="<util:message key='ct.msg.info.inptSrchWrd'/>" value="<c:out value='${boardSttVO.srchKey}'/>" />
        <a href="javascript:;" onclick="ebList.srchBulletin();" class="btn search" title="<util:message key='ct.label.ttl.srch'/>"><util:message key="ct.label.ttl.srch"/></a>
        <div class="btn_wrap R">
            <c:if test="${boardVO.writableYn == 'Y'}">
                <c:if test="${boardVO.mergeType == 'A'}">
                    <a href="javascript:;" target="_self" class="btn blue" onclick="ebList.writeBulletin();" title="<util:message key='ct.label.btn.reg'/>"><span><util:message key="ct.label.btn.reg"/></span></a>
                </c:if>
            </c:if>
        </div>
    </fieldset>
</form>
<div class="total">
    <div class="select_wrap">
        <span><util:message key="ct.label.ttl.total"/><span> <fmt:formatNumber value="${boardSttVO.totalBltns}" pattern="#,##0" /></span> <util:message key="ct.label.ttl.case"/></span>
    </div>
</div>
<!-- table -->
<form name="frmlist" onsubmit="return false">
    <section class="table_wrap">
        <ul class="board_list<c:if test="${empty bltnList}"> list_none</c:if>">
            <li class="thead C">
                <c:if test="${boardVO.ttlNoYn == 'Y'}">
                    <div class="th t_none"><util:message key="ct.label.ttl.no"/></div>
                </c:if>
                <div class="th t_none"><util:message key="ct.label.ttl.cate"/></div>
                <div class="th title"><util:message key="ct.label.ttl.title"/></div>
                <c:if test="${boardVO.listAtchYn == 'Y'}">
                    <div class="th t_none"><util:message key="ct.label.ttl.file"/></div>
                </c:if>
                <c:if test="${boardVO.ttlNickYn == 'Y'}">
                    <div class="th t_none"><util:message key="ct.label.ttl.writer"/></div>
                </c:if>
                <c:if test="${boardVO.ttlRegYn == 'Y'}">
                    <div class="th t_none"><util:message key="ct.label.ttl.writ.dt"/></div>
                </c:if>
                <c:if test="${boardVO.ttlReadYn == 'Y'}">
                    <div class="th t_none"><util:message key="ct.label.ttl.views"/></div>
                </c:if>
                <div class="th"><util:message key="ct.label.ttl.prog.ans"/></div>
                <!-- 확장필드 사용 시 -->
                <c:if test="${boardVO.extUseYn == 'Y'}">
                    <c:set var="rsExtnMapper" value="${boardVO.bltnExtnMapper}" />
                    <c:if test="${rsExtnMapper.ext_str0Yn == 'Y' && rsExtnMapper.ext_str0TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str0Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str1Yn == 'Y' && rsExtnMapper.ext_str1TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str1Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str2Yn == 'Y' && rsExtnMapper.ext_str2TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str2Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str3Yn == 'Y' && rsExtnMapper.ext_str3TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str3Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str4Yn == 'Y' && rsExtnMapper.ext_str4TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str4Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str5Yn == 'Y' && rsExtnMapper.ext_str5TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str5Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str6Yn == 'Y' && rsExtnMapper.ext_str6TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str6Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str7Yn == 'Y' && rsExtnMapper.ext_str7TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str7Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str8Yn == 'Y' && rsExtnMapper.ext_str8TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str8Ttl}</div>
                    </c:if>
                    <c:if test="${rsExtnMapper.ext_str9Yn == 'Y' && rsExtnMapper.ext_str9TtlYn == 'Y'}">
                        <div class="th t_none">${rsExtnMapper.ext_str9Ttl}</div>
                    </c:if>
                </c:if>
            </li>
            <c:if test="${empty bltnList}">
                <li class="tbody C list_none">
                    <div class="td">
                        <util:message key="ct.label.ttl.notFoundData"/>
                    </div>
                </li>
            </c:if>
            <c:if test="${!empty bltnList}">
                <c:forEach items="${bltnList}" var="list">
                    <li class="tbody C">
                        <c:if test="${boardVO.ttlNoYn == 'Y'}">
                            <c:if test="${list.boardRow == '0'}">
                                <div class="td notice t_none">공지</div>
                            </c:if>
                            <c:if test="${list.boardRow != '0'}">
                                <div class="td t_none"><c:out value="${list.boardRow}"/></div>
                            </c:if>
                        </c:if>
                        <div class="td t_none">
                            <c:choose>
                                <c:when test="${!empty list.eachBoardVO.boardNm}">
                                    <c:out value="${list.eachBoardVO.boardNm}"/>
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${boardVO.boardNm}"/>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="td title L<c:if test="${list.bltnLev != '1'}"> answer</c:if><c:if test="${boardVO.ttlNewYn == 'Y'}"><c:if test="${list.recentBltn == 'Y'}"> new</c:if></c:if>">
                                <%--게시판이 가상게시판일 수도 있으므로, 게시물이 아니라 게시물이 속한 게시판의 boardId 를 이용하여 읽기화면으로 가야 한다.--%>
                            <c:if test="${list.readable == 'true'}">
                                <c:if test="${boardVO.mergeType == 'A'}">
                                    <a style="cursor: pointer;" title="${list.bltnOrgSubj}" onclick="ebList.readBulletin('<c:out value="${boardVO.boardId}"/>','<c:out value="${list.bltnNo}"/>')">
                                        <c:out value="${list.bltnOrgSubj}"/>
                                    </a>
                                </c:if>
                                <c:if test="${boardVO.mergeType != 'A'}">
                                    <a style="cursor: pointer;" title="${list.bltnOrgSubj}" onclick="ebList.readBulletin('<c:out value="${list.eachBoardVO.boardId}"/>','<c:out value="${list.bltnNo}"/>')">
                                        <c:out value="${list.bltnOrgSubj}"/>
                                    </a>
                                </c:if>
                            </c:if>
                            <c:if test="${list.readable == 'false'}">
                                <a style="cursor: pointer;" title="${list.bltnOrgSubj}" onclick="alert('작성자가 글읽기를 허용하지 않았습니다');">
                                    <c:out value="${list.bltnOrgSubj}"/>
                                </a>
                            </c:if>
                        </div>
                        <c:if test="${boardVO.listAtchYn == 'Y'}">
                            <c:if test="${empty list.fileList}">
                                <div class="td t_none"></div>
                            </c:if>
                            <c:if test="${!empty list.fileList}">
                                <c:forEach items="${list.fileList}" var="fList">
                                    <div class="td file t_none"></div>
                                </c:forEach>
                            </c:if>
                        </c:if>
                        <c:if test="${boardVO.ttlNickYn == 'Y'}">
                            <c:set var="arrUsrNic" value="${fn:split(list.userNick,'^')}"/>
                            <div class="td t_none "><c:out value="${arrUsrNic[0]}"/></div>
                        </c:if>
                        <c:if test="${boardVO.ttlRegYn == 'Y'}">
                            <div class="td t_none"><c:out value="${list.regDatimSF}"/></div>
                        </c:if>
                        <c:if test="${boardVO.ttlReadYn == 'Y'}">
                            <div class="td t_none"><fmt:formatNumber value="${list.bltnReadCnt}" pattern="#,##0" /></div>
                        </c:if>
                        <c:if test="${list.delFlag == 'N'}">
                            <div class="td"><c:out value="${list.cateNm}"/></div>
                        </c:if>
                        <c:if test="${boardVO.extUseYn == 'Y'}">
                            <c:if test="${extnMapper.ext_str0Yn == 'Y' && extnMapper.ext_str0TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str0}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str1Yn == 'Y' && extnMapper.ext_str1TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str1}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str2Yn == 'Y' && extnMapper.ext_str2TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str2}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str3Yn == 'Y' && extnMapper.ext_str3TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str3}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str4Yn == 'Y' && extnMapper.ext_str4TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str4}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str5Yn == 'Y' && extnMapper.ext_str5TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str5}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str6Yn == 'Y' && extnMapper.ext_str6TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str6}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str7Yn == 'Y' && extnMapper.ext_str7TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str7}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str8Yn == 'Y' && extnMapper.ext_str8TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str8}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                            <c:if test="${extnMapper.ext_str9Yn == 'Y' && extnMapper.ext_str9TtlYn == 'Y'}">
                                <c:if test="${list.delFlag == 'N'}">
                                    <c:if test="${!empty list.bltnExtnVO}">
                                        <div class="td t_none"><c:out value="${list.bltnExtnVO.ext_str9}"/></div>
                                    </c:if>
                                </c:if>
                            </c:if>
                        </c:if>
                    </li>
                </c:forEach>
            </c:if>
        </ul>
    </section>
</form>
<!-- 페이징 -->
<div class="paging" id="pageIndex">
</div>
<!-- 페이징// -->
<!-- </body> -->
<script type="text/javascript">
    var currentPage = <c:out value="${boardSttVO.page}"/>;
    var totalPage   = <c:out value="${boardSttVO.totalPage}"/>;
    var setSize     = 10; <%--하단 Page Iterator에서의 Navigation 갯수--%>
    var imgUrl      = "/gnu/images/board/";
    var color       = "808080";

    var afpImg = "arrow_LL_blue_dark.png";
    var pfpImg = "arrow_LL_blue.png";
    var alpImg = "arrow_RR_blue_dark.png";
    var plpImg = "arrow_RR_blue.png";
    var apsImg = "arrow_L_blue_dark.png";
    var ppsImg = "arrow_L_blue.png";
    var ansImg = "arrow_R_blue_dark.png";
    var pnsImg = "arrow_R_blue.png";

    var startPage;
    var endPage;
    var cursor;
    var curList = "";
    var prevSet = "";
    var nextSet = "";
    var firstP  = "";
    var lastP   = "";

    moduloCP = (currentPage - 1) % setSize / setSize ;
    startPage = Math.ceil((((currentPage - 1) / setSize) - moduloCP)) * setSize + 1;
    moduloSP = ((startPage - 1) + setSize) % setSize / setSize;
    endPage   = Math.ceil(((((startPage - 1) + setSize) / setSize) - moduloSP)) * setSize;

    if (totalPage <= endPage) endPage = totalPage;
    if (currentPage > setSize) {
        firstP = "<li><a href='javascript:;' onclick='ebList.next(1);' class='btn_first' title='<util:message key='ct.label.ttl.firstPage'/>'></a></li>";//첫 페이지로 이동
        cursor = startPage - 1;
        prevSet = "<li><a href='javascript:;' onclick='ebList.next('"+cursor+"');' class='btn_prev' title='<util:message key='ct.label.ttl.prevPage'/>'></a></li>";//이전 페이지로 이동
    } else {
        firstP  = "<li><a href='javascript:;' onclick='ebList.next(1);' class='btn_first' title='<util:message key='ct.label.ttl.firstPage'/>'></a></li>";//첫 페이지로 이동
        prevSet = "<li><a href='javascript:;' class='btn_prev' title='<util:message key='ct.label.ttl.prevPage'/>'></a></li>";//이전 페이지로 이동
    }

    cursor = startPage;
    curList += "<div class='page-w'>";
    while( cursor <= endPage ) {
        if( cursor == currentPage ){
            curList += "<li class='on'><a href='javascript:;' title='"+cursor+"' onclick=ebList.next('"+cursor+"')>"+cursor+"</a></li>";
        }else{
            curList += "<li><a href='javascript:;'  title='"+cursor+"' onclick=ebList.next('"+cursor+"')>"+cursor+"</a></li>";
        }
        cursor++;
    }
    curList += "</div>";
    curList += "<div class='page-m'><span>"+currentPage+"<span>/"+endPage+"</span></span></div>";
    if ( totalPage > endPage) {
        lastP = "<li><a href='javascript:;' onclick='ebList.next("+totalPage+");' class='btn_last' title='<util:message key='ct.label.ttl.lastPage'/>'></a></li>";//마지막 페이지로 이동
        cursor = endPage + 1;
        nextSet = "<li><a href='javascript:;' onclick='ebList.next('"+cursor+"');' class='btn_next' title='<util:message key='ct.label.ttl.nextPage'/>'></a></li>";//다음 페이지로 이동
    } else {
        lastP  = "<li><a href='javascript:;' onclick='ebList.next("+totalPage+");' class='btn_last' title='<util:message key='ct.label.ttl.lastPage'/>'></a></li>";//마지막 페이지로 이동
        nextSet = "<li><a href='javascript:;' class='btn_next' title='<util:message key='ct.label.ttl.nextPage'/>'></a></li>";//다음 페이지로 이동
    }

    curList = "<ul>"+firstP+prevSet+curList+nextSet+lastP+"</ul>";
    document.getElementById("pageIndex").innerHTML = curList;
</script>

<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<%@page import="com.serotonin.mango.vo.UserComment"%>

<tag:page dwr="DataPointDetailsDwr" js="view" onload="init">
  <script type="text/javascript">

    mango.view.initPointDetails();
    
    function init() {
        getHistoryTableData();
        <c:if test="${!empty periodType}">
          DataPointDetailsDwr.getDateRangeDefaults(${periodType}, ${periodCount}, function(data) {
              setDateRange(data);
              getImageChart();
          });
        </c:if>
        <c:if test="${!empty flipbookLimit}">getFlipbookChart();</c:if>
        getStatsChart();
        
        jQuery("#datPointDetailsPointSelect").chosen({
			allow_single_deselect: true,
			placeholder_text_single: " ",
			search_contains: true,
			width: "400px"
       	});
    }
    
    //
    // History
    //
    function getHistoryTableData() {
        var limit = parseInt($get("historyLimit"));
        if (isNaN(limit))
            alert("<fmt:message key="pointDetails.recordCountError"/>");
        else {
            startImageFader($("historyLimitImg"));
            DataPointDetailsDwr.getHistoryTableData(limit, function(response) {
            	var data = response.data.history;
                dwr.util.removeAllRows("historyTableData");
                if (!data || data.length == 0)
                    dwr.util.addRows("historyTableData", ["<fmt:message key="common.noData"/>"], [function(data) { return data; }]);
                else {
                    dwr.util.addRows("historyTableData", data,
                        [
                            function(data) { return data.value; },
                            function(data) { return data.time; },
                            function(data) { return data.annotation; }
                        ],
                        {
                            rowCreator:function(options) {
                                var tr = document.createElement("tr");
                                tr.className = "rowTable"+ (options.rowIndex % 2 == 0 ? "" : "Alt");
                                return tr;
                            }
                        });
                }
                $("historyTableAsof").innerHTML = response.data.asof;
                stopImageFader($("historyLimitImg"));
            });
        }
    }
    
    //
    // Image chart
    //
    function getImageChart() {
        var width = dojo.html.getContentBox($("imageChartDiv")).width - 20;
        DataPointDetailsDwr.getImageChartData($get("fromYear"), $get("fromMonth"), $get("fromDay"), $get("fromHour"),
                $get("fromMinute"), $get("fromSecond"), $get("fromNone"), $get("toYear"), $get("toMonth"), $get("toDay"), $get("toHour"),
                $get("toMinute"), $get("toSecond"), $get("toNone"), width, 350, function(response) {
            $("imageChartDiv").innerHTML = response.data.chart;
            $("imageChartAsof").innerHTML = response.data.asof;
            stopImageFader($("imageChartImg"));
        });
        startImageFader($("imageChartImg"));
    }
    
    //
    // Stats chart
    //
    function getStatsChart() {
        var period = parseInt($get("statsChartDuration"));
        var periodType = parseInt($get("statsChartDurationType"));
        
        if (isNaN(period))
            alert("<fmt:message key="pointDetails.timePeriodError"/>");
        else {
            startImageFader($("statsChartImg"));
            DataPointDetailsDwr.getStatsChartData(periodType, period, true, function(response) {
                $("statsChartData").innerHTML = response.data.stats;
                $("statsAsof").innerHTML = response.data.asof;
                stopImageFader($("statsChartImg"));
            });
        }
    }
    
     function togglePanel(imgNode, panelId) {
				if (!imgNode.minimized) {
					imgNode.className = "bi bi-arrows-expand align-middle ms-3 fs-5";
					imgNode.title = "<fmt:message key="common.maximize"/>";
					hide(panelId);
					imgNode.minimized = true;
				}
				else {
					imgNode.className = "bi bi-arrows-collapse align-middle ms-3 fs-5";
					imgNode.title = "<fmt:message key="common.minimize"/>";
					show(panelId);
					imgNode.minimized = false;
				}
			}
    
    // Flipbook
    function getFlipbookChart() {
        var limit = parseInt($get("flipbookLimit"));
        if (isNaN(limit))
            alert("<fmt:message key="pointDetails.imageCountError"/>");
        else {
            startImageFader($("flipbookChartImg"));
            DataPointDetailsDwr.getFlipbookData(limit, function(response) {
                var data = response.data.images;
                var thumbContent = "";
                for (var i=0; i<data.length; i++)
                    thumbContent += '<img src="'+ data[i].uri +'?w=40&h=40" onmouseover="swapFlipbookImage(\''+ data[i].uri +'\')"/>';
                $set("flipbookThumbsDiv", thumbContent);
                if (data.length > 0)
                    swapFlipbookImage(data[0].uri);
                
                $("flipbookAsof").innerHTML = response.data.asof;
                stopImageFader($("flipbookChartImg"));
            });
        }
    }
    
    function swapFlipbookImage(uri) {
        $("flipbookImage").src = uri;
    }
    
    jQuery(document).ready(function(){
    	(function($) {
    		loadjscssfile("resources/jQuery/plugins/chosen/chosen.min.css","css"); 	
			loadjscssfile("resources/jQuery/plugins/chosen/chosen.jquery.min.js","js");
		})(jQuery);
    });

    
    //função para adicionar classes aos selects e checkbox estilo bootstrap
    function addClassToSelectsPointDetails() {
    var selectGroups = [
      {
      ids: ["datPointDetailsPointSelect", "statsChartDurationType"],
      classes: ["w-50", "form-select", "form-select-sm", "me-2"]
      },
      {
        ids: ["fromMonth", "fromDay", "fromHour", "fromMinute", "fromSecond", "toMonth", "toDay", "toHour", "toMinute", "toSecond"],
        classes: ["form-select", "form-select-sm", "my-2"]
      }
    ];

    selectGroups.forEach(function(group) {
      group.ids.forEach(function(id) {
      var selectElement = document.getElementById(id);
      if (selectElement) {
        selectElement.classList.add(...group.classes);
      }
      });
    });
    }

    // Chama a função após a página ser carregada
    window.onload = addClassToSelectsPointDetails;
  </script>
  
  <table class="w-100">
    <tr>
      <td valign="top" align="right">
        <fmt:message key="pointDetails.goto"/>:&nbsp;
        <sst:select id="datPointDetailsPointSelect" value="${point.id}" onchange="window.location='data_point_details.shtm?dpid='+ this.value;">
          <c:forEach items="${userPoints}" var="point">
            <sst:option value="${point.id}">${point.extendedName}</sst:option>
          </c:forEach>
        </sst:select>

        <c:if test="${!empty prevId}">
            <i class="bi bi-caret-left-square-fill text-blue-add  align-middle ms-3 fs-5" title="<fmt:message key='pagination.previous'/>" onclick="window.location='data_point_details.shtm?dpid=${prevId}'" style="cursor: pointer;"></i>
        </c:if>
        
        <c:if test="${!empty nextId}">
            <i class="bi bi-caret-right-square-fill text-blue-add  align-middle ms-3 fs-5" title="<fmt:message key='pagination.next'/>" onclick="window.location='data_point_details.shtm?dpid=${nextId}'" style="cursor: pointer;"></i>
        </c:if>
      </td>
    </tr>
  </table>
  
  <table class="w-100" cellspacing="0" cellpadding="0">
    <tr>
      <td valign="top">
        <div class="left-menu h-100 my-3">
          <table>
            <tr>
              <td class="smallTitle" colspan="2"><i class="bi bi-search align-middle me-3 fs-5" title="<fmt:message key='common.point'/>"></i>
                ${point.name}
                <c:if test="${pointEditor}">
                    <a href="data_point_edit.shtm?dpid=${point.id}" title="<fmt:message key='pointDetails.editPoint'/>">
                        <i class="bi bi-pencil-square align-middle ms-3 fs-5"></i>
                    </a>
                    <a href="data_source_edit.shtm?dsid=${point.dataSourceId}&pid=${point.id}" title="<fmt:message key='pointDetails.editDataSource'/>">
                        <i class="bi bi-database-fill-gear align-middle ms-3 fs-5"></i>
                    </a>
                </c:if>
              </td>
            </tr>
            <tr>
              <td class="formLabelRequired align-middle "><fmt:message key="common.value"/></td>
              <td id="pointValue" class="formField"></td>
            </tr>
            <tr>
              <td class="formLabelRequired align-middle"><fmt:message key="common.time"/></td>
              <td id="pointValueTime" class="formField"></td>
            </tr>
            <tr id="pointChangeNode" style="display:none">
              <td class="formLabelRequired align-middle">
                <i id="pointChanging" class="bi bi-tools align-middle ms-3 fs-5" title="<fmt:message key='common.set'/>"></i>
                <fmt:message key="common.set"/>
              </td>
              <td id="pointChange" class="formField d-flex align-items-center justify-content-center"></td>
            </tr>
            <tr>
            <tr>
              <td class="formLabelRequired align-middle"><fmt:message key="common.xid"/></td>
              <%-- WebContent/WEB-INF/snippet/changeContentText.jsp --%>
              <td class="formField">${point.xid}</td>
            </tr>
            <td colspan="2" id="pointMessages"></td></tr>
          </table>
        </div>
        
        <div class="left-menu h-100 my-3">
            <table class="w-100 my-3">
            <tr>
              <div class="my-3">
                <span class="smallTitle"><fmt:message key="pointDetails.statistics"/></span>
                <div id="statsAsof"></div>
              </div>
              <%-- <td class="smallTitle"><fmt:message key="pointDetails.statistics"/></td> --%>
              <td><fmt:message key="pointDetails.timePeriod"/>:</td>
              <td class="d-flex align-items-center justify-content-center">
                <%-- <fmt:message key="pointDetails.timePeriod"/>: --%>
                <input class="form-control form-control-sm m-2" id="statsChartDuration" style="text-align:right;" type="text" class="formVeryShort"
                        value='${empty periodCount ? "1" : periodCount}'/>
                <sst:select id="statsChartDurationType" value="${periodType}">
                  <tag:timePeriodOptions sst="true" min="true" h="true" d="true" w="true" mon="true"/>
                </sst:select>
                  <a href="#" id="statsChartImg" title="<fmt:message key='pointDetails.getStatistics'/>" onclick="getStatsChart()">
                      <i class="bi bi-play-circle-fill text-blue-add  align-middle me-5 fs-3"></i>
                  </a>
              </td>
            </tr>
          </table>
          <div class="my-3" id="statsChartData" style="padding:0px 0px 5px 5px;"></div>
        </div>
      </td>
      
      <td valign="top" class="pb-3">
        <div class="left-menu h-100 my-3">
            <table class="w-100 my-3">
            <tr>
              <td  class="p-2 text-center smallTitle"><fmt:message key="pointDetails.history"/></td>
              <td id="historyTableAsof"></td>
              <td align="right" class="d-flex align-items-center justify-content-center">
                <td class="p-2 text-center"><fmt:message key="pointDetails.show"/></td>
                <td class="col-2 text-center"><input class="form-control form-control-sm my-2 formVeryShort" id="historyLimit" type="text" style="text-align:right;" value="${historyLimit}"/></td>
                <td class="p-2 text-center"><fmt:message key="pointDetails.mostRecentRecords"/></td>
                <td><a href="#" id="historyLimitImg" title="<fmt:message key='pointDetails.getData'/>" onclick="getHistoryTableData()">
                    <i class="bi bi-play-circle-fill text-blue-add  align-middle ms-3 fs-3"></i>
                </a></td>
              </td>
            </tr>
          </table>
          <table cellspacing="1" class="text-center table table-light table-hover">
            <tr class="rowHeader">
              <td><fmt:message key="common.value"/></td>
              <td><fmt:message key="common.time"/></td>
              <td><fmt:message key="common.annotation"/></td>
            </tr>
            <tbody id="historyTableData"></tbody>
          </table>
        </div>
      </td>
      
      <td valign="top">
        <div class="left-menu h-100 my-3">
            <table class="w-100 my-3">
            <tr>
              <td class="smallTitle"><fmt:message key="notes.userNotes"/></td>
              <td align="right">
                  <a href="#" title="<fmt:message key='notes.addNote'/>" onclick="openCommentDialog(${applicationScope['constants.UserComment.TYPE_POINT']}, ${point.id})">
                      <i class="bi bi-chat-dots align-middle ms-3 fs-5"></i>
                  </a>
              </td>
            </tr>
          </table>
          <table id="pointComments${point.id}" class="table table-light table-hover align-middle"><tag:comments comments="${point.comments}"/></table>
        </div>
      </td>
    </tr>
    
    <c:if test="${!empty periodType}">
      <tr>
        <td colspan="3" class="pb-3">
          <!--  chart with editable properties and annotations -->
          <div class="left-menu h-100">
            <table class="w-100 my-3">
              <tr>
                <td class="smallTitle"><fmt:message key="pointDetails.chart"/></td>
                <td id="imageChartAsof"></td>
                <td align="right"><tag:dateRange/></td>
                <td>
                  <a href="#" id="imageChartImg" title="<fmt:message key='pointDetails.imageChartButton'/>" onclick="getImageChart()">
                      <i class="bi bi-play-circle-fill text-blue-add  align-middle ms-3 fs-3"></i>
                  </a>
              </tr>
              <tr><td colspan="3" id="imageChartDiv"></td></tr>
            </table>
          </div>
        </td>
      </tr>
    </c:if>
    
    <c:if test="${!empty flipbookLimit}">
      <tr>
        <td colspan="3" class="pb-3">
          <div class="borderDiv marB">
            <table class="w-100">
              <tr>
                <td class="smallTitle"><fmt:message key="pointDetails.flipbook"/></td>
                <td id="flipbookAsof"></td>
                <td align="right">
                  <fmt:message key="pointDetails.images"/>:
                  <input class="form-control form-control-sm my-2" id="flipbookLimit" style="text-align:right;" type="text" value="${flipbookLimit}"
                          class="formVeryShort"/>
                  <a href="#" id="flipbookChartImg" title="<fmt:message key='pointDetails.getImages'/>" onclick="getFlipbookChart()">
                      <i class="bi bi-play-circle-fill text-blue-add "></i>
                  </a>
                </td>
              </tr>
              <tr><td colspan="2" id="flipbookThumbsDiv"></td></tr>
              <tr><td colspan="2"><img id="flipbookImage" src=""/></td></tr>
            </table>
          </div>
        </td>
      </tr>
    </c:if>
  
    <tr>
      <td colspan="3" class="pb-3">
        <div class="left-menu h-100">
            <table class="w-100 my-3">
            <tr>
              <td class="smallTitle"><fmt:message key="pointDetails.events"/></td>
              <td align="right">
                <i class="bi bi-arrows-collapse align-middle ms-3 fs-5" title="<fmt:message key='common.maximize'/>" onclick="togglePanel(this, 'eventsTable');"></i>
                <a href="#" title="<fmt:message key='common.refresh'/>">
                    <i class="bi bi-arrow-clockwise align-middle ms-3 fs-5"></i>
                </a>
              </td>
            </tr>
          </table>
          <table id="eventsTable" cellspacing="1" cellpadding="0" class="w-100 table table-light table-hover" >
            <tr class="rowHeader">
              <td><fmt:message key="pointDetails.id"/></td>
              <td><fmt:message key="common.alarmLevel"/></td>
              <td><fmt:message key="common.activeTime"/></td>
              <td><fmt:message key="pointDetails.message"/></td>
              <td><fmt:message key="common.status"/></td>
              <td><fmt:message key="events.acknowledged"/></td>
            </tr>
            
            <c:forEach items="${events}" var="event" varStatus="status" end="19">
              <tr class="rowTable<c:if test="${status.index % 2 == 1}">Alt</c:if>">
                <td align="center">${event.id}</td>
                <td align="center"><tag:eventIcon event="${event}"/></td>
                <td>${sst:time(event.activeTimestamp)}</td>
                <td>
                  <table cellspacing="0" cellpadding="0" class="w-100">
                    <tr>
                      <td><b><sst:i18n message="${event.message}"/></b></td>
                      <td align="right">
                          <i class="bi bi-plus-square align-middle ms-3 fs-5" title="<fmt:message key='notes.addNote'/>" onclick="openCommentDialog(${applicationScope['constants.UserComment.TYPE_EVENT']}, ${event.id})" style="cursor: pointer;"></i>
                      </td>
                    </tr>
                  </table>
                  <table cellspacing="0" cellpadding="0" id="eventComments${event.id}">
                    <c:forEach items="${event.eventComments}" var="comment">
                      <tr>
                        <td valign="top" width="16">
                            <i class="bi bi-chat-left-text align-middle ms-3 fs-5" title="<fmt:message key='notes.note'/>"></i>
                        </td>
                        <td valign="top">
                          <span class="copyTitle">
                            ${comment.prettyTime} <fmt:message key="notes.by"/>
                            <c:choose>
                              <c:when test="${empty comment.username}"><fmt:message key="common.deleted"/></c:when>
                              <c:otherwise><c:out value="${comment.username}"/></c:otherwise>
                            </c:choose>
                          </span><br/>
                          <c:out value="${comment.comment}"/>
                        </td>
                      </tr>
                    </c:forEach>
                  </table>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${event.active}">
                      <fmt:message key="common.active"/>
                      <a href="events.shtm"><tag:img png="flag_white" title="common.active"/></a>
                    </c:when>
                    <c:when test="${!event.rtnApplicable}"><fmt:message key="common.nortn"/></c:when>
                    <c:otherwise>
                      ${sst:time(event.rtnTimestamp)} - <sst:i18n message="${event.rtnMessage}"/>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:if test="${event.acknowledged}">
                    ${sst:time(event.acknowledgedTimestamp)}
                    <sst:i18n message="${event.ackMessage}"/>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${sst:size(events) > 20}">
              <tr class="row"><td align="center" colspan="6"><fmt:message key="pointDetails.maxEvents"/> ${sst:size(events)}</td></tr>
            </c:if>
            <c:if test="${empty events}">
              <tr class="row"><td colspan="6"><fmt:message key="events.emptyList"/></td></tr>
            </c:if>
          </table>
        </div>
      </td>
    </tr>

    <c:set var="isRoles" value="${!empty sessionUser && sessionUser.getAttribute('roles') != null}" />
    <c:set var="isRoleAdmin" value="${isRoles && sessionUser.getAttribute('roles').contains('ROLE_ADMIN')}" />
    <c:set var="isRoleUser" value="${isRoles && sessionUser.getAttribute('roles').contains('ROLE_USER')}" />
    <c:if test="${isRoleAdmin || isRoleUser}">
    <tr>
      <td valign="top" class="pb-3">
        <div class="left-menu h-100">
          <span class="smallTitle" style="margin:3px;"><fmt:message key="pointDetails.views"/></span>
          <table class="w-100" cellspacing="1">
            <tr class="rowHeader">
              <td><fmt:message key="pointDetails.name"/></td>
              <td></td>
            </tr>
            <c:forEach items="${views}" var="view" varStatus="status">
              <tr class="my-3 rowTable<c:if test="${status.index % 2 == 1}">Alt</c:if>">
                <td>${view.name}</td>
                <td align="center">
                  <a href="views.shtm?viewId=${view.id}" title="<fmt:message key='pointDetails.gotoView'/>">
                      <i class="bi bi-diagram-3 align-middle ms-3 fs-5"></i>
                  </a>
                </td>
            </c:forEach>
            <c:if test="${empty views}">
              <tr class="rowTable"><td colspan="2"><fmt:message key="pointDetails.notInView"/></td></tr>
            </c:if>
          </table>
        </div>
      </td>
      </c:if>
      <c:if test="${isRoleAdmin}">
      <td colspan="2" valign="top">
        <div class="left-menu h-100">
          <span class="smallTitle" style="margin:3px;"><fmt:message key="pointDetails.userAccess"/></span>
          <table cellspacing="1"  class="text-center table table-light table-hover w-100 my-3">
            <tr class="rowHeader">
              <td width="16"></td>
              <td><fmt:message key="pointDetails.username"/></td>
              <td><fmt:message key="pointDetails.accessType"/></td>
            </tr>
            <c:forEach items="${users}" var="userData" varStatus="status">
              <tr class="rowTable<c:if test="${status.index % 2 == 1}">Alt</c:if>">
                <c:set var="user" value="${userData.user}"/>
                <td><%@ include file="/WEB-INF/snippet/userIcon.jsp" %></td>
                <td><c:out value="${user.username}"/></td>
                <td>
                  <c:choose>
                    <c:when test="${userData.accessType == applicationScope['constants.Permissions.DataPointAccessTypes.READ']}"><fmt:message key="common.access.read"/></c:when>
                    <c:when test="${userData.accessType == applicationScope['constants.Permissions.DataPointAccessTypes.SET']}"><fmt:message key="common.access.set"/></c:when>
                    <c:when test="${userData.accessType == applicationScope['constants.Permissions.DataPointAccessTypes.DATA_SOURCE']}"><fmt:message key="common.access.dataSource"/></c:when>
                    <c:when test="${userData.accessType == applicationScope['constants.Permissions.DataPointAccessTypes.ADMIN']}"><fmt:message key="common.access.admin"/></c:when>
                    <c:otherwise><fmt:message key="common.unknown"/> (${userData.accessType})</c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
          </table>
        </div>
      </td>
    </tr>
    </c:if>
  </table>
  
  <%@ include file="/WEB-INF/jsp/include/userComment.jsp" %>
</tag:page>
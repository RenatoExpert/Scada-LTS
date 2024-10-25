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
<tag:page dwr="PublisherListDwr" onload="init">
  <script type="text/javascript">
    function init() {
        PublisherListDwr.init(function(response) {
            dwr.util.addOptions("publisherTypes", response.data.types, "key", "message");
            updatePublisherList(response.data.publishers);
        });
    }
    
    function addPublisher() {
        window.location = "publisher_edit.shtm?typeId="+ $get("publisherTypes");
    }
    
    function updatePublisherList(publishers) {
        dwr.util.removeAllRows("publisherList");
        dwr.util.addRows("publisherList", publishers,
            [
                function(p) { return "<b>"+ p.name +"</b>"; },
                function(p) { return p.typeMessage; },
                function(p) { return p.configDescription; },
                function(p) {
                    if (p.enabled)
                        return '<i class="bi bi-wifi text-primary align-middle me-2 fs-5" title="<fmt:message key="common.enabledToggle"/>" onclick="togglePublisher('+ p.id +')" id="pImg'+ p.id +'"></i>';
                        return '<i class="bi bi-wifi-off text-danger align-middle me-2 fs-5" title="<fmt:message key="common.disabledToggle"/>" onclick="togglePublisher('+ p.id +')" id="pImg'+ p.id +'"></i>';
                },
                function(p) {
                    return '<a href="publisher_edit.shtm?pid='+ p.id +'"><i class="bi bi-pencil-square align-middle me-2 fs-5" border="0" title="<fmt:message key="common.edit"/>"></i></a> '+
                        '<i class="bi bi-trash text-danger align-middle me-2 fs-5" title="<fmt:message key="common.delete"/>" id="deleteImg'+ p.id +'" onclick="deletePublisher('+ p.id +')"</i>';
                }
            ],
            {
                rowCreator: function(options) {
                    var tr = document.createElement("tr");
                    tr.id = "publisherRow"+ options.rowData.id;
                    tr.className = "rowTable"+ (options.rowIndex % 2 == 0 ? "" : "Alt");
                    return tr;
                },
                cellCreator: function(options) {
                    var td = document.createElement("td");
                    if (options.cellNum == 3)
                        td.align = "center";
                    return td;
                }
            });
        display("noPublishers", publishers.length == 0);
    }
    
    function togglePublisher(id) {
        var imgNode = $("pImg"+ id);
        if (!hasImageFader(imgNode)) {
            PublisherListDwr.togglePublisher(id, function(result) {
                updateStatusImg($("pImg"+ result.data.id), result.data.enabled);
                updateStatusImg(imgNode, result.data.enabled);
            });
            startImageFader(imgNode);
        }
    }
    
    
    function deletePublisher(id) {
        if (confirm("<fmt:message key="publisherList.deleteConfirm"/>")) {
            startImageFader("deleteImg"+ id);
            PublisherListDwr.deletePublisher(id, function(publisherId) {
                stopImageFader("deleteImg"+ publisherId);
                var rowTable = $("publisherRow"+ publisherId);
                rowTable.parentNode.removeChild(rowTable);
            });
        }
    }
    
    function updateStatusImg(imgNode, enabled) {
        stopImageFader(imgNode);
        setPublisherStatusImg(enabled, imgNode);
    }
  </script>
  
  <table class="subPageHeader container">
    <div>
    <td valign="top">
    <div class="right-box m-3" style="height: 500px;">
        <div class="d-flex justify-content-between align-items-center m-3">
          <div class="d-flex align-items-center">
            <%-- <i class="bi bi-broadcast-pin" title="<sst:i18n key='publisherList.publishers' escapeDQuotes='true'/>"></i> --%>
            <span class="smallTitle"><fmt:message key="publisherList.publishers"/></span>
            <tag:help id="publisherList"/>
          </div>
          <div class="d-flex align-items-center">
            <select class="form-select form-select-sm" id="publisherTypes"></select>
            <i class="bi bi-plus-circle-fill text-blue-add align-middle ms-3 fs-5" title="<sst:i18n key='common.add' escapeDQuotes='true'/>" onclick="addPublisher()"></i>
          </div>
        </div>
        <div class="container">
          <div class="d-flex justify-content-center">
            <div class="right-box">
              <table cellspacing="1" class="table table-light table-hover">
                <div class="rowHeader">
                  <td><fmt:message key="publisherList.name"/></td>
                  <td><fmt:message key="publisherList.type"/></td>
                  <td><fmt:message key="publisherList.config"/></td>
                  <td><fmt:message key="publisherList.status"/></td>
                  <td></td>
                </div>
                <tbody id="noPublishers" style="display:none">
                <div><td colspan="5"><fmt:message key="publisherList.noRows"/></td></div></tbody>
                <tbody id="publisherList"></tbody>
              </table>
            </div>
          </div>
        </div>
    </div>
    </td>
    </div>
  </table>
</tag:page>
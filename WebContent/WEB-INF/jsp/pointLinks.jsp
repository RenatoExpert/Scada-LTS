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
<%@page import="com.serotonin.mango.Common"%>
<%@page import="com.serotonin.mango.vo.link.PointLinkVO"%>
<c:set var="NEW_ID"><%= Common.NEW_ID %></c:set>

<tag:page dwr="PointLinksDwr" onload="init">
  <script type="text/javascript">
    var sourcePoints;
    var editingPointLink;
    
    function init() {
        PointLinksDwr.init(function(response) {
            sourcePoints = response.sourcePoints;
            
            // Add points to source and target selects
            dwr.util.addOptions("sourcePointId", response.sourcePoints, "key", "value");
            dwr.util.addOptions("targetPointId", response.targetPoints, "key", "value");
            
            // Create the list of existing links
            for (var i=0; i<response.pointLinks.length; i++) {
                appendPointLink(response.pointLinks[i].id);
                updatePointLink(response.pointLinks[i]);
            }
            
            <c:if test="${!empty param.plid}">
              showPointLink(${param.plid});
            </c:if>
        });
    }
    
    function showPointLink(plId) {
        if (editingPointLink)
            stopImageFader($("pl"+ editingPointLink.id +"Img"));
        PointLinksDwr.getPointLink(plId, function(pl) {
            if (!editingPointLink)
                show("pointLinkDetails");
            editingPointLink = pl;
            
            $set("xid", pl.xid);
            $set("sourcePointId", pl.sourcePointId);
            $set("targetPointId", pl.targetPointId);
            $set("script", pl.script);
            $set("event", pl.event);
            $set("disabled", pl.disabled);
            
            setUserMessage();
        });
        startImageFader($("pl"+ plId +"Img"));
        display("deletePointLinkImg", plId != ${NEW_ID});
    }
    
    function savePointLink() {
        setUserMessage();
        hideContextualMessages("pointLinkDetails")
        PointLinksDwr.savePointLink(editingPointLink.id, $get("xid"), $get("sourcePointId"), $get("targetPointId"),
                $get("script"), $get("event"), $get("disabled"), function(response) {
            if (response.hasMessages)
                showDwrMessages(response.messages);
            else {
                if (editingPointLink.id == ${NEW_ID}) {
                    stopImageFader($("pl"+ editingPointLink.id +"Img"));
                    editingPointLink.id = response.data.plId;
                    appendPointLink(editingPointLink.id);
                    startImageFader($("pl"+ editingPointLink.id +"Img"));
                    setUserMessage("<fmt:message key="pointLinks.pointLinkAdded"/>");
                    show($("deletePointLinkImg"));
                }
                else
                    setUserMessage("<fmt:message key="pointLinks.pointLinkSaved"/>");
                PointLinksDwr.getPointLink(editingPointLink.id, updatePointLink);
            }
        });
    }
    
    function setUserMessage(message) {
        if (message) {
            show("userMessage");
            $set("userMessage", message);
        }
        else
            hide("userMessage");
    }
    
    function appendPointLink(plId) {
        createFromTemplate("pl_TEMPLATE_", plId, "pointLinksTable");
    }
    
    function updatePointLink(pl) {
        $set("pl"+ pl.id +"Name", getPointName(pl.sourcePointId) +'</td><td><i class="bi bi-caret-right-square-fill text-success ms-3 me-3 sound-icon"></i></td><td>'+ getPointName(pl.targetPointId));
        setPointLinkImg(pl.disabled, $("pl"+ pl.id +"Img"));
    }
    
    function getPointName(pointId) {
        for (var i=0; i<sourcePoints.length; i++) {
            if (sourcePoints[i].key == pointId)
                return sourcePoints[i].value;
        }
        return null;
    }
    
    function deletePointLink() {
        PointLinksDwr.deletePointLink(editingPointLink.id, function() {
            stopImageFader($("pl"+ editingPointLink.id +"Img"));
            $("pointLinksTable").removeChild($("pl"+ editingPointLink.id));
            hide("pointLinkDetails");
            editingPointLink = null;
        });
    }
    
    function validateScript() {
        PointLinksDwr.validateScript($get("script"), $get("sourcePointId"), $get("targetPointId"),
                function(response) {
            showDwrMessages(response.messages);
        });
    }
  </script>
  
  <table class="subPageHeader container">
    <tr>
      <td valign="top">
        <div class="left-menu">
          <div class="top-row-box mb-3">
            <div class="box-description sound-icon">
              <span class="smallTitle"><fmt:message key="pointLinks.pointLinks"/></span>
              <tag:help id="pointLinks"/>
            </div>
            <div class="sound-icon">
                  <i class="bi bi-plus-circle-fill text-blue-add" title="<fmt:message key='common.add'/>"
                    onclick="showPointLink(${NEW_ID})" id="pl${NEW_ID}Img"></i>
            </div>
          </div>
          <div class="top-row-box mb-3">
          <table id="pointLinksTable" class="table table-hover">
            <tbody id="pl_TEMPLATE_" onclick="showPointLink(getMangoId(this))" class="ptr" style="display:none">
              <tr>
                <td style="width: 10px">
                  <i id="pl_TEMPLATE_Img" class="bi bi-link" title="<fmt:message key='pointLinks.pointLink'/>" style="display:none"></i>
                </td>
                <td class="text-uppercase" id="pl_TEMPLATE_Name" style="display: flex; align-items: center;"></td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </td>
      
      <td valign="top" style="display:none;" id="pointLinkDetails">
        <div class="right-box">
            <div class="top-row-box mb-3">
              <div class="box-description">
              <span class="smallTitle"><fmt:message key="pointLinks.details"/></span>
              </div>
              <div class="edit-button">
                <i class="bi bi-floppy2-fill text-blue-add  me-1" onclick="savePointLink();" title="<fmt:message key='common.save'/>"></i>
                  <span style="font-size: 16px;">
                  <fmt:message key='common.save'/>
                  </span>
                <i id="deletePointLinkImg" class="bi bi-trash text-danger" onclick="deletePointLink();" title="<fmt:message key='common.delete'/>"></i>
                  <span style="font-size: 16px;">
                  <fmt:message key='common.delete'/>
                  </span>
              </div>
            </div>
          
          <table>
            <form>
            <div class="custom-padding-form mb-3">
              <div class="mb-3 row">
              <label for="xid" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="common.xid"/></label>
              <div class="col-sm-7 custom-padding-is">
                <input type="text" class="form-control" id="xid"/>
                </div>
              </div>
              <div class="mb-3 row">
                <label for="dataSourceId" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="pointLinks.source"/></label>
                <div class="col-sm-6 custom-padding-is">
                  <select id="sourcePointId" class="form-select"></select>
                </div>
              </div>
              <div class="mb-3 row">
                <label for="alias" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="pointLinks.target"/></label>
                <div class="col-sm-6 custom-padding-is">
                  <select id="targetPointId" class="form-select"></select>
                </div>
              </div>
              <div class="mb-3 row">
                <label for="scheduleType" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="pointLinks.event"/></label>
                <div class="col-sm-4 custom-padding-is">
                  <select id="event" class="form-select form-select-sm">
                    <option value="<c:out value="<%= PointLinkVO.EVENT_CHANGE %>"/>"><fmt:message key="pointLinks.event.change"/></option>
                    <option value="<c:out value="<%= PointLinkVO.EVENT_UPDATE %>"/>"><fmt:message key="pointLinks.event.update"/></option>
                  </select>
                </div>
              <div class="mb-3 row">
                <label for="disabled" class="col-sm-2 col-form-label custom-padding-l"><fmt:message key="common.disabled"/></label>
                <div class="col-sm-2 custom-padding-is">
                <input type="checkbox" class="form-check-input custom-checkbox" id="disabled">
              </div>
              </div>
              <div class="mb-3 row">
                <%-- <fmt:message key="pointLinks.script"/>
                <i class="bi bi-check-circle-fill text-success" onclick="validateScript();" title="<fmt:message key='pointLinks.validate'/>"></i>
              </td>
              <td> --%>
                  <label for="script" class="form-label"><fmt:message key="pointLinks.script"/></label>
                  <div class="d-flex flex-column align-items-start">
                <textarea class="form-control mb-3" id="script" name="script" rows="10" cols="40"></textarea>
                <div class="align-self-end">
                      <%-- <i class="bi bi-check-circle-fill text-success edit-button" onclick="validateScript();" title="<fmt:message key='pointLinks.validate'/>"></i>
                      <span style="font-size: 16px;">
                      <fmt:message key='pointLinks.validate'/>
                      </span> --%>
                      <button type="button" class="btn btn-primary custom-btn-blue" name="script" onclick="validateScript();"><sst:i18n key='pointLinks.validate' escapeDQuotes='true'/></button>
                      </div>
                  </div>
            
            <%-- <tr>
              <td class="formLabel"><fmt:message key="common.disabled"/></td>
              <td class="formField"><input type="checkbox" id="disabled"/></td>
            </tr> --%>
            </div>
            </form>
          </table>
          
          <table>
            <tr>
              <td colspan="2" id="userMessage" class="formError" style="display:none;"></td>
            </tr>
          </table>
        </div>
      </td>
    </tr>
  </table>
</tag:page>
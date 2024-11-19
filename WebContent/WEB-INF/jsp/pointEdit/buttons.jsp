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
<%@page import="org.scada_lts.web.mvc.controller.DataPointEditController"%>
<div class="right-box my-3">
	<table class="w-100 m-3">
    <tr>
      <td colspan="2" align="center">
        <button type="submit" id="buttonsave" class="btn btn-primary custom-btn-blue ms-3" onclick="return doSave('<%= DataPointEditController.SUBMIT_SAVE %>');" ><fmt:message key="common.save"/></button>
        <%-- <input type="submit" value="<fmt:message key="common.save"/>" onclick="return doSave('<%= DataPointEditController.SUBMIT_SAVE %>');"/> --%>
        <c:choose>
          <c:when test="${form.enabled}">
            <button type="submit" id="buttondisable" class="btn btn-primary custom-btn-blue ms-3" onclick="return doSave('<%= DataPointEditController.SUBMIT_DISABLE %>');" ><fmt:message key="pointEdit.buttons.disable"/></button>
            <%-- <input type="submit" value="<fmt:message key="pointEdit.buttons.disable"/>" onclick="return doSave('<%= DataPointEditController.SUBMIT_DISABLE %>');"/> --%>
            <button type="submit" id="buttonrestart" class="btn btn-primary custom-btn-blue ms-3" onclick="return doSave('<%= DataPointEditController.SUBMIT_RESTART %>');" ><fmt:message key="pointEdit.buttons.restart"/></button>
            <%-- <input type="submit" value="<fmt:message key="pointEdit.buttons.restart"/>" onclick="return doSave('<%= DataPointEditController.SUBMIT_RESTART %>');"/> --%>
          </c:when>
          <c:otherwise>
            <button type="submit" id="buttonenable" class="btn btn-primary custom-btn-blue ms-3" onclick="return doSave('<%= DataPointEditController.SUBMIT_ENABLE %>');" ><fmt:message key="pointEdit.buttons.enable"/></button>
            <%-- <input type="submit" value="<fmt:message key="pointEdit.buttons.enable"/>" onclick="return doSave('<%= DataPointEditController.SUBMIT_ENABLE %>');"/> --%>
          </c:otherwise>
        </c:choose>
        
        <button type="submit" id="buttoncancel" class="btn btn-primary custom-btn-blue ms-3" onclick="window.location='data_source_edit.shtm?dsid=${dataSource.id}&pid=${form.id}';" ><fmt:message key="common.cancel"/></button>
        <%-- <input type="button" value="<fmt:message key="common.cancel"/>" onclick="window.location='data_source_edit.shtm?dsid=${dataSource.id}&pid=${form.id}';"/> --%>
      </td>
      <td></td>
    </tr>
    
    <tr class="d-flex justify-content-center my-2">
      <td colspan="2"><fmt:message key="pointEdit.buttons.note"/></td>
    </tr>
  </table>
</div>
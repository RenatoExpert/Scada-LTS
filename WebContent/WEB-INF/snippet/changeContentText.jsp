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
<%@ include file="/WEB-INF/snippet/common.jsp" %>
<table class="w-100">
    <tr>
        <td class="m-3 formLabelRequired">
            <fmt:message key="common.enterSetPoint"/>:<br/>
        </td>
    </tr>
    <tr>
        <td class="d-flex align-items-center justify-content-start">
            <input class="w-75 form-control form-control-sm m-2" id="txtChange${componentId}" type="text" value="${mango:rawText(point, pointValue)}" 
                onkeypress="if (event.keyCode==13) $('txtSet${componentId}').onclick();"/>
            <tb></tb>
            <button id="txtSet${componentId}" class="btn btn-primary btn-sm custom-btn-blue ms-2"
                onclick="mango.view.setPoint(${point.id}, '${componentId}', $('txtChange${componentId}').value);">
                <fmt:message key="common.set"/>
            </button>
        </td>
    <%-- 
        <button type="button" id="txtSet${componentId}" class="btn btn-primary custom-btn-blue" name="txtSet${componentId}">
            <sst:i18n key='common.set' escapeDQuotes='true' onclick="mango.view.setPoint(${point.id}, '${componentId}', $('txtChange${componentId}').value);"/>
        </button> 
    --%>
    <tr><td  class="formLabelRequired" align="center">
    <c:if test="${!hideClosingHint}"> Clique duas vezes para fechar </c:if>
    </td>
    </tr></tr>
</table>
<tag:relinquish/>

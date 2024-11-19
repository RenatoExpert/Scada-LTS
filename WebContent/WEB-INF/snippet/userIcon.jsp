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
<c:choose>
  <c:when test="${user.disabled}"><i class="bi bi-person-fill text-secondary align-middle m-3 fs-5" title="<fmt:message key='common.disabled'/>"></i></c:when>
  <c:when test="${user.admin}"><i class="bi bi-person-fill text-danger align-middle m-3 fs-5" title="<fmt:message key='common.administrator'/>"></i></c:when>
  <c:otherwise><i class="bi bi-person-fill text-success align-middle m-3 fs-5" title="<fmt:message key='common.user'/>"></i></c:otherwise>
</c:choose>
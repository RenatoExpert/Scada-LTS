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

<tag:page onload="setFocus">
  <script type="text/javascript">
    function setFocus() {
        $("sqlString").focus();
    }

    function showResultDiv() {
        document.getElementById("resultDiv").style.display = "block";
    }

    window.onload = function() {
        // Verifica se a div deve ser exibida após a recarga da página
        if (${form.data != null}) {
            showResultDiv();
        }
    }
  </script>
  
  <table class="subPageHeader container">
    <tr>
      <td>
      <div class="right-box text-center">
        <form action="sql.shtm" method="post">
          <table class="mx-auto">
            <spring:bind path="form.sqlString">
              <tr>
                <div class="top-row-box mb-3">
                  <div class="box-description sound-icon">
                    <span class="smallTitle"><fmt:message key="sql.sql"/></span>
                    <tag:help id="directQuerying"/>
                  </div>
                </div>
                <div class="top-row-box mb-3">
                </td>
                <td>
                  <label for="sqlString" class="form-label">Preencher com QUERY SQL</label>
                  <div class="d-flex flex-column align-items-start">
                    <textarea class="form-control mb-3" id="sqlString" name="sqlString" rows="8" cols="80"><c:out value="${status.value}"/></textarea>
                    <div class="align-self-end">
                      <button type="submit" class="btn btn-primary custom-btn-blue" name="query" onclick="showResultDiv()"><fmt:message key="sql.query"/></button>
                    </div>
                  </div>
                </td>
              </tr>
            </spring:bind>
            <tr>
              <td colspan="2"><fmt:message key="sql.warning"/></td>
            </tr>
              <tr>
                <c:if test="${form.error != null}"><td colspan="2" class="formError"><c:out value="${form.error}"/></td></c:if>
              </tr>
          </table>
        </form>
          <div class="top-row-box mb-3">
          <div id="resultDiv" class="right-box table-responsive w-75 h-50 overflow-auto mx-auto" style="display: none;">
          <div class="top-row-box mb-3">
          <c:if test="${form.data != null}">
            <table cellspacing="1" class="table table-light table-hover">
              <tr class="rowHeader">
                <c:forEach items="${form.headers}" var="rowHeader">
                  <td>${rowHeader}</td>
                </c:forEach>
              </tr>
              
              <c:forEach items="${form.data}" var="rowTable">
                <tr class="rowTable">
                  <c:forEach items="${rowTable}" var="col">
                    <td><c:out value="${col}"/></td>
                  </c:forEach>
                </tr>
              </c:forEach>
            </table>
          </c:if>

          <c:if test="${form.updateResult > -1}">
            ${form.updateResult} <fmt:message key="sql.rowsUpdated"/>
          </c:if>
          
          </div>
          </div>
          </div>
      </div>
      </td>
    </tr>
  </table>
</tag:page>
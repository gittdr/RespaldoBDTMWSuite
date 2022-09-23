SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- JET - PTS 14997 - 7/25/02, changed the stored procedure to use the new table RM00103_TMW to do the updates.
-- It also only will only pull customer information for those that are active and have a credit limit assigned.

CREATE PROC [dbo].[gp_agingupdate_sp] 
AS
DELETE FROM creditcheck
 WHERE cmp_id IN (SELECT custnmbr FROM RM00103_TMW) or alt_id in (SELECT custnmbr FROM RM00103_TMW)

-- JET - PTS #10765 - 5/1/01, changed the code because it was producing a duplicate key error on the insert.
--INSERT INTO creditcheck (cmp_id, cmp_aging1, cmp_aging2, cmp_aging3, cmp_aging4, cmp_aging5, cmp_aging6) 
--(SELECT custnmbr, agperamt_1, agperamt_2, agperamt_3, agperamt_4, agperamt_5, agperamt_6 + agperamt_7 
--   FROM RM00103)
--KPM pts #13095 restrict the insert to companies in the rm00103 table
-- 64048 DPETE add check for exclude_from_creditcheck for OrdInvStatus
 /* 64048  */
 DECLARE @ordInvStatus table (abbr varchar(6))
 INSERT into @OrdInvStatus(abbr) 
 SELECT abbr
 FROM labelfile
 WHERE labeldefinition = 'OrdInvStatus'
 AND Isnull(exclude_from_creditcheck,'N') = 'N'
 AND abbr <> 'UNK'
 
INSERT INTO creditcheck (cmp_id, alt_id) 
	SELECT distinct(cmp_id), cmp_altid 
		FROM company 
		WHERE cmp_id IN (SELECT custnmbr FROM RM00103_TMW) or cmp_altid in (SELECT custnmbr FROM RM00103_TMW)
UPDATE creditcheck 
   SET cmp_aging1 = agperamt_1, 
       cmp_aging2 = agperamt_2, 
       cmp_aging3 = agperamt_3, 
       cmp_aging4 = agperamt_4, 
       cmp_aging5 = agperamt_5, 
       cmp_aging6 = agperamt_6 + agperamt_7 
  FROM RM00103_TMW
 WHERE cmp_id = custnmbr or alt_id = custnmbr 
       and crlmttyp = 2

--KPM - PTS #13868 ADD CODE TO HANDLE UPDATING AVAILABLE CREDIT FIELDS.
update company  
   set cmp_creditavail = IsNull(cmp_creditlimit, 0) - IsNull((Select IsNull(creditcheck.cmp_aging1, 0) + IsNull(creditcheck.cmp_aging2, 0) + IsNull(creditcheck.cmp_aging3, 0) + IsNull(creditcheck.cmp_aging4, 0) + IsNull(creditcheck.cmp_aging5, 0) + IsNull(creditcheck.cmp_aging6, 0) 
                                                                from creditcheck 
                                                               where creditcheck.cmp_id = company.cmp_id), 0)

 where IsNull(cmp_billto, 'N') = 'Y'
  
update company 
   set cmp_creditavail = cmp_creditavail - IsNull((Select sum(ivh_totalcharge) 
                                                     from invoiceheader  WITH (NOLOCK) 
                                                    where ivh_billto = cmp_id 
                                                      and ivh_invoicestatus in (select abbr 
                                                                                  from labelfile 
                                                                                 where labeldefinition = 'InvoiceStatus' 
                                                                                   and IsNull(exclude_from_creditcheck, 'N') = 'N')), 0) 
 where IsNull(cmp_billto, 'N') = 'Y'

--KPM - PTS #13894 ADD ORDERS COMPLETED BUT NOT YET INVOICED TO THE UPDATING OF THE AVAILABLE CREDIT FIELDS.
update company 
   set cmp_creditavail = cmp_creditavail - IsNull((Select sum(ord_totalcharge) 
                                                     from orderheader WITH (NOLOCK) 
                                                     join @ordInvStatus istatus on orderheader.ord_invoicestatus = istatus.abbr  --64048
                                                    where ord_billto = cmp_id 
                                                      -- 64048 and ord_invoicestatus in ('AVL','PND') 
                                                      and ord_hdrnumber > 0 
                                                      and ord_status in (select abbr 
                                                                           from labelfile 
                                                                          where labeldefinition = 'DispStatus' 
                                                                            and Isnull(exclude_from_creditcheck,'N') = 'N')), 0)
 where IsNull(cmp_billto, 'N') = 'Y'

GO
GRANT EXECUTE ON  [dbo].[gp_agingupdate_sp] TO [public]
GO

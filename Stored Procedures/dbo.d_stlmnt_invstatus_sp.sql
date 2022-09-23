SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_stlmnt_invstatus_sp](@mov_number INT)
AS

/**
 * 
 * NAME:
 * d_stlmnt_invstatus_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 *    Returns Invoice Status for a Move
 *
 * RETURNS:
 *    NONE
 *    
 *
 * RESULT SETS: 
 *    ord_number              VARCHAR(12)
 *    ivh_invoicenumber       VARCHAR(12)
 *    ivh_ivhstatusid         INTEGER
 *    ivh_invoicestatus       VARCHAR(6)
 *    ivh_ivhstatusdesc       VARCHAR(20)
 *    ivh_billto              VARCHAR(8)
 *    ivh_billdate            DATETIME
 *    inv_linehaul_charge     MONEY
 *    inv_fuel_charge         MONEY
 *    inv_accessorial_charge  MONEY
 *    ivh_totalcharge         MONEY
 *    pw_status               VARCHAR(10)
 *
 * PARAMETERS:
 *    @mov_number
 * 
 * REVISION HISTORY:
 * 09/14/2010 PTS 51904 SPN - Initial Version
 * 
 **/

BEGIN

   DECLARE @ivh_invoicenumber VARCHAR(12)
   DECLARE @ivh_invoicestatus VARCHAR(6)
   DECLARE @ivh_mbstatus      VARCHAR(6)
   DECLARE @invstatus_code    INT
   DECLARE @mbstatus_code     INT
   
   CREATE TABLE #temp
   ( ord_number               VARCHAR(12) NULL
   , ivh_invoicenumber        VARCHAR(12) NULL
   , ivh_invoicestatus        VARCHAR(6)  NULL
   , ivh_mbstatus             VARCHAR(6)  NULL
   , ivh_billto               VARCHAR(8)  NULL
   , ivh_billdate             DATETIME    NULL
   , inv_linehaul_charge      MONEY       NULL
   , inv_fuel_charge          MONEY       NULL
   , inv_accessorial_charge   MONEY       NULL
   , ivh_totalcharge          MONEY       NULL
   , pw_required_count        INTEGER     NULL
   , pw_received_count        INTEGER     NULL
   , pw_status                VARCHAR(10) NULL
   )

   CREATE TABLE #temp_status
   ( ivh_ivhstatusid    INTEGER
   , ivh_invoicestatus  VARCHAR(6)
   )
   
   DECLARE myCUR CURSOR FOR
   SELECT t.ivh_invoicenumber AS ivh_invoicenumber
        , t.ivh_invoicestatus AS ivh_invoicestatus
        , t.ivh_mbstatus      AS ivh_mbstatus
        , IsNull(l1.code,-1)  AS invstatus_code
        , IsNull(l2.code,-1)  AS mbstatus_code
     FROM #temp t
   LEFT OUTER JOIN labelfile l1 ON t.ivh_invoicestatus = l1.abbr
                               AND l1.labeldefinition   = 'InvoiceStatus'
   LEFT OUTER JOIN labelfile l2 ON t.ivh_mbstatus = l2.abbr
                               AND l2.labeldefinition   = 'InvoiceStatus'
   
   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(1,'XXX')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(2,'HLD')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(3,'HLA')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(4,'RTP')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(5,'NTP')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(6,'PRN')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(7,'PRO')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(8,'XFR')

   INSERT INTO #temp_status(ivh_ivhstatusid,ivh_invoicestatus)
   VALUES(9,'CLD')

   INSERT INTO #temp
   ( ord_number
   , ivh_invoicenumber
   , ivh_invoicestatus
   , ivh_mbstatus
   , ivh_billto
   , ivh_billdate
   , inv_linehaul_charge
   , inv_fuel_charge
   , inv_accessorial_charge
   , ivh_totalcharge
   , pw_required_count
   , pw_received_count
   , pw_status
   )
   SELECT o.ord_number                                AS ord_number
        , i.ivh_invoicenumber                         AS ivh_invoicenumber
        , i.ivh_invoicestatus                         AS ivh_invoicestatus
        , i.ivh_mbstatus                              AS ivh_mbstatus
        , IsNull(i.ivh_billto,o.ord_billto)           AS ivh_billto
        , i.ivh_billdate                              AS ivh_billdate
        , (CASE WHEN i.ivh_invoicenumber IS NULL THEN
                  o.ord_charge
             ELSE dbo.fn_inv_linehaul_charge(i.ivh_hdrnumber)
           END
          )                                           AS inv_linehaul_charge
        , (CASE WHEN i.ivh_invoicenumber IS NULL THEN
                  dbo.fn_ord_fuel_charge(o.ord_hdrnumber)
             ELSE dbo.fn_inv_fuel_charge(i.ivh_hdrnumber)
           END
          )                                           AS inv_fuel_charge
        , (CASE WHEN i.ivh_invoicenumber IS NULL THEN
                  dbo.fn_ord_accessorial_charge(o.ord_hdrnumber)
             ELSE dbo.fn_inv_accessorial_charge(i.ivh_hdrnumber)
           END
          )                                           AS inv_accessorial_charge
        , (CASE WHEN i.ivh_invoicenumber IS NULL THEN
                  IsNull(o.ord_charge,0) +
                  IsNull(dbo.fn_ord_accessorial_charge(o.ord_hdrnumber),0) +
                  IsNull(dbo.fn_ord_fuel_charge(o.ord_hdrnumber),0)
             ELSE i.ivh_totalcharge
           END
          )                                           AS ivh_totalcharge
        , (SELECT COUNT(1)
             FROM billdoctypes bdt
             JOIN labelfile l ON bdt.bdt_doctype = l.abbr
            WHERE IsNull(l.retired,'N') = 'N'
              AND bdt.bdt_inv_required = 'Y'
              AND bdt.cmp_id = i.ivh_billto
          )                                           AS pw_required_count
        , (SELECT COUNT(1)
             FROM billdoctypes bdt
             JOIN labelfile l ON bdt.bdt_doctype = l.abbr
             JOIN paperwork pw ON bdt.bdt_doctype = pw.abbr
            WHERE IsNull(l.retired,'N') = 'N'
              AND bdt.bdt_inv_required = 'Y'
              AND bdt.cmp_id = i.ivh_billto
              AND pw.ord_hdrnumber = i.ord_hdrnumber
              AND IsNull(pw.pw_received,'N') = 'Y'
              AND pw.pw_dt IS NOT NULL
          )                                           AS pw_received_count
        , 'None'                                      AS pw_status
     FROM orderheader o
   LEFT OUTER JOIN invoiceheader i ON o.ord_hdrnumber = i.ord_hdrnumber
    WHERE o.mov_number = @mov_number

   UPDATE #temp
      SET pw_status = 'No'
    WHERE pw_required_count > pw_received_count

   UPDATE #temp
      SET pw_status = 'Yes'
    WHERE pw_required_count > 0
      AND pw_received_count >= pw_required_count


   --massage the ivh_invoicestatus as Invoice entry screen
   OPEN myCUR
   FETCH NEXT
    FROM myCUR
    INTO @ivh_invoicenumber, @ivh_invoicestatus, @ivh_mbstatus, @invstatus_code, @mbstatus_code
   WHILE @@FETCH_STATUS = 0
   BEGIN
      If @mbstatus_code > @invstatus_code AND @ivh_invoicestatus <> 'HLA'
      Begin
         UPDATE #temp
            SET ivh_invoicestatus = @ivh_mbstatus
          WHERE ivh_invoicenumber = @ivh_invoicenumber
      End
       
      FETCH NEXT
       FROM myCUR
       INTO @ivh_invoicenumber, @ivh_invoicestatus, @ivh_mbstatus, @invstatus_code, @mbstatus_code
   END
   CLOSE myCUR
   DEALLOCATE myCUR

   --Result
   SELECT t.ord_number                       AS ord_number
        , t.ivh_invoicenumber                AS ivh_invoicenumber
        , IsNull(ts.ivh_ivhstatusid,1)       AS ivh_ivhstatusid
        , IsNull(t.ivh_invoicestatus,'XXX')  AS ivh_invoicestatus
        , IsNull(lbl.name,'Not Prepared')    AS ivh_ivhstatusdesc
        , t.ivh_billto
        , t.ivh_billdate
        , t.inv_linehaul_charge
        , t.inv_fuel_charge
        , t.inv_accessorial_charge
        , t.ivh_totalcharge
        , t.pw_status
     FROM #temp t
   LEFT OUTER JOIN #temp_status ts ON t.ivh_invoicestatus = ts.ivh_invoicestatus
   LEFT OUTER JOIN labelfile lbl ON t.ivh_invoicestatus = lbl.abbr
                                 AND lbl.labeldefinition = 'InvoiceStatus'

END
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_invstatus_sp] TO [public]
GO

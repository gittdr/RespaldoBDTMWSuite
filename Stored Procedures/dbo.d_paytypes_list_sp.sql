SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_paytypes_list_sp]
AS

SET NOCOUNT ON

/* Revision History:
   Date        Name              Label    Description
   ----------- ---------------   -------  ------------------------------------------------------------------------------------

   03/06/2013  JSwindell         63055    Changes related to adding new paytype column: pyt_oblig
   05/21/2013  vjh               64871    added maintenance flag
   09/19/2013  vjh               71977    added heirarchy and adjust with negative
   04/11/2014  SPN               76379    added pyt_PayTypeBasisUnitRule_Id
   06/02/2014  SPN               78185    added TaxCount
   07/03/2014  JDS				 66749    added pyt_category
   03/10/2015  vjh				 85922    added pyt_requireaudit
  
*/



BEGIN

   DECLARE @tempbrasgntp TABLE
   ( pyt_itemcode VARCHAR(6)
   , branchcount  INT
   , PRIMARY KEY(pyt_itemcode)
   )

   DECLARE @gi_string1 VARCHAR(60)

   SELECT @gi_string1 = gi_string1
     FROM generalinfo
    WHERE gi_name = 'HourlyOTPay'

   INSERT INTO @tempbrasgntp
   ( pyt_itemcode
   , branchcount
   )
   SELECT bat_value
        , COUNT(1)
     FROM branch_assignedtype
    WHERE bat_type = 'PAYTYPE'
   GROUP BY bat_value

   SELECT pt.pyt_number                      AS pyt_number
        , pt.pyt_itemcode                    AS pyt_itemcode
        , pt.pyt_description                 AS pyt_description
        , pt.pyt_basis                       AS pyt_basis
        , pt.pyt_basisunit                   AS pyt_basisunit
        , pt.pyt_quantity                    AS pyt_quantity
        , pt.pyt_rateunit                    AS pyt_rateunit
        , pt.pyt_unit                        AS pyt_unit
        , pt.pyt_rate                        AS pyt_rate
        , pt.pyt_pretax                      AS pyt_pretax
        , pt.pyt_minus                       AS pyt_minus
        , pt.pyt_editflag                    AS pyt_editflag
        , pt.pyt_pr_glnum                    AS pyt_pr_glnum
        , pt.pyt_ap_glnum                    AS pyt_ap_glnum
        , pt.pyt_status                      AS pyt_status
        , pt.pyt_agedays                     AS pyt_agedays
        , pt.pyt_fee1                        AS pyt_fee1
        , pt.pyt_fee2                        AS pyt_fee2
        , pt.pyt_accept_negatives            AS pyt_accept_negatives
        , pt.pyt_fservprocess                AS pyt_fservprocess
        , pt.pyt_expchk                      AS pyt_expchk
        , pt.pyt_systemcode                  AS pyt_systemcode
        , pt.pyt_maxrate                     AS pyt_maxrate
        , pt.pyt_maxenf                      AS pyt_maxenf
        , pt.pyt_minrate                     AS pyt_minrate
        , pt.pyt_minenf                      AS pyt_minenf
        , pt.pyt_zeroenf                     AS pyt_zeroenf
        , pt.pyt_incexcoth                   AS pyt_incexcoth
        , pt.pyt_retired                     AS pyt_retired
        , pt.pyt_paying_to                   AS pyt_paying_to
        , pt.pyt_offset_percent              AS pyt_offset_percent
        , pt.pyt_offset_for                  AS pyt_offset_for
        , pt.pyt_editindispatch              AS pyt_editindispatch
        , pt.pyt_class                       AS pyt_class
        , pt.pyt_classflag                   AS pyt_classflag
        , IsNull(pt.pyt_group,'UNK')         AS pyt_group
        , pt.gp_tax                          AS gp_tax
        , pt.cht_itemcode                    AS cht_itemcode
        , pt.pyt_authcode_required           AS pyt_authcode_required
        , pt.pyt_otflag                      AS pyt_otflag
        , pt.pyt_eiflag                      AS pyt_eiflag
        , 0                                  AS pyt_pr_glnum_clearing_visible
        , 0                                  AS pyt_ap_glnum_clearing_visible
        , pt.pyt_pr_glnum_clearing           AS pyt_pr_glnum_clearing
        , pt.pyt_ap_glnum_clearing           AS pyt_ap_glnum_clearing
        , pt.pyt_exclude_guaranteed_pay      AS pyt_exclude_guaranteed_pay
        , pt.pyt_superv_delete_only          AS pyt_superv_delete_only
        , pt.pyt_tppcode                     AS pyt_tppcode
        , @gi_string1                        AS otpay
        , (CASE pt.pyt_basisunit
            WHEN 'TIM' THEN 1
            ELSE 0
           END
          )                                  AS c_time
        , IsNull(tb.branchcount,0)           AS branchcount
        , pt.pyt_payto_splittype             AS pyt_payto_splittype
        , pt.pyt_offset_for_splittype        AS pyt_offset_for_splittype
        , pt.pyt_rtd_exclude                 AS pyt_rtd_exclude
        , pt.pyt_offset_basis                AS pyt_offset_basis
        , pt.pyt_taxable                     AS pyt_taxable
        , pt.pyt_exclude_3pp                 AS pyt_exclude_3pp
        , pt.pyt_holiday_vacation            AS pyt_holiday_vacation
        , pt.pyt_GarnishmentClassification   AS pyt_GarnishmentClassification
        , pt.pyt_currency                    AS pyt_currency
        , pt.pyt_oblig                       AS pyt_oblig
        , pt.pyt_maintenance                 AS pyt_maintenance
        , pt.pyt_AdjustWithNegativePay       AS pyt_AdjustWithNegativePay
        , pt.pyt_sth_abbr                    AS pyt_sth_abbr
        , pt.pyt_sth_priority                AS pyt_sth_priority
        , pt.pyt_PayTypeBasisUnitRule_Id     AS pyt_PayTypeBasisUnitRule_Id
        , (SELECT COUNT(1) FROM PayItemTax pit WHERE pit.pyt_number = pt.pyt_number) As TaxCount
        , IsNull( pt.pyt_category,'UNK')  	 AS pyt_category   
        , pyt_requireaudit  				 AS pyt_requireaudit   
     FROM paytype pt
   LEFT OUTER JOIN @tempbrasgntp tb ON pt.pyt_itemcode = tb.pyt_itemcode
   WHERE pt.pyt_itemcode NOT IN ('CARRY0','CARRYD')	-- these paycodes are for .net only

END
GO
GRANT EXECUTE ON  [dbo].[d_paytypes_list_sp] TO [public]
GO

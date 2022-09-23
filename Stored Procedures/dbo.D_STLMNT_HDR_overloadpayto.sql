SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[D_STLMNT_HDR_overloadpayto](@payheader  int,
         @paydate datetime,
         @asgn_type  varchar(6),
         @asgn_id    varchar(13),
         @payto      varchar(12))

AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 7-23-2009 JSwindell   PTS 47021   Add Columns.  payee_invoice_number(x30),  payee_invoice_date (datetime)
 * 05/20/2011   - pts54402 - vjh - add payto as a pseudo asgn_type for pay headers
 * 06/14/2012 SPN PTS63407 - increasing width of @asgn_id to 13; VJH PTS61373 - increasing width of @payto to 12
 *
 **/

declare @dummy varchar(9),
   @varchar8 varchar(8),
   @varchar45 varchar(45),
   @varchar30 varchar(30),
   @varchar4 varchar(4),
   @varchar10 varchar(10),
   @payto_flag char(1)

IF @asgn_type = 'DRV'
BEGIN
   IF (SELECT mpp_payto
       FROM   manpowerprofile
       WHERE  mpp_id = @asgn_id) <> 'UNKNOWN'
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         payto.pto_altid,
         payto.pto_ssn,
         payto.pto_address1,
         payto.pto_address2,
         payto.pto_city,
         payto.pto_zip,
         payto.pto_phone1,
         payto.pto_lastfirst,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         manpowerprofile.mpp_lastfirst,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021

      FROM payheader  LEFT OUTER JOIN  payto  ON  (payheader.pyh_payto  = payto.pto_id) ,
            manpowerprofile
         WHERE    @asgn_type = 'DRV' and
               (payheader.asgn_id = manpowerprofile.mpp_id) and
               (payheader.pyh_pyhnumber = @payheader OR
                  (payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
   ELSE
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         manpowerprofile.mpp_otherid,
         manpowerprofile.mpp_ssn,
         manpowerprofile.mpp_address1,
         manpowerprofile.mpp_address2,
         manpowerprofile.mpp_city,
         manpowerprofile.mpp_zip,
         manpowerprofile.mpp_homephone,
         manpowerprofile.mpp_lastfirst,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         manpowerprofile.mpp_lastfirst,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021

      FROM payheader,
                 manpowerprofile
         WHERE    @asgn_type = 'DRV' and
         (payheader.asgn_id = manpowerprofile.mpp_id) and
               (payheader.pyh_pyhnumber = @payheader OR

                  (payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
END

IF @asgn_type = 'TRC'
BEGIN
   IF (SELECT trc_owner
       FROM   tractorprofile
       WHERE  trc_number = @asgn_id) <> 'UNKNOWN'
      SELECT @payto_flag = 'P'
   ELSE
      SELECT @payto_flag = 'T'
END
IF @asgn_type = 'TRL'
BEGIN
   IF (SELECT trl_owner
       FROM   trailerprofile
       WHERE  trl_id = @asgn_id) <> 'UNKNOWN'
       --WHERE  trl_number = @asgn_id) <> 'UNKNOWN' --PTS# 24460 ILB 05/13/2005
      SELECT @payto_flag = 'P'
   ELSE
      SELECT @payto_flag = 'T'
END

IF @asgn_type = 'TRC' OR @asgn_type = 'TRL'
BEGIN
   IF @payto_flag = 'P'
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         payto.pto_altid,
         payto.pto_ssn,
         payto.pto_address1,
         payto.pto_address2,
         payto.pto_city,
         payto.pto_zip,
         payto.pto_phone1,
         payto.pto_lastfirst,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         @varchar45,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021
      FROM payheader LEFT OUTER JOIN payto on payheader.pyh_payto = payto.pto_id
         WHERE    @asgn_type in ('TRC', 'TRL') and
               (payheader.pyh_pyhnumber = @payheader OR
                  (payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
               AND (@payto='' or @payto = payheader.pyh_payto)
   ELSE
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         @varchar8,
         @dummy,
         @varchar30,
         @varchar30,
         0,
         @dummy,
         @varchar10,
         @varchar45,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         @varchar45,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021
      FROM payheader
         WHERE    @asgn_type in ('TRC', 'TRL') and
         (payheader.pyh_pyhnumber = @payheader OR
                  (payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
         AND (@payto='' or @payto = payheader.pyh_payto)
END

IF @asgn_type = 'CAR'
BEGIN
   IF (SELECT pto_id
       FROM   carrier
       WHERE  car_id = @asgn_id) <> 'UNKNOWN'
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         payto.pto_altid,
         payto.pto_ssn,
         payto.pto_address1,
         payto.pto_address2,
         payto.pto_city,
         payto.pto_zip,
         payto.pto_phone1,
         payto.pto_lastfirst,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         carrier.car_name,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021
      FROM payheader  LEFT OUTER JOIN  payto  ON  payheader.pyh_payto  = payto.pto_id ,
            carrier
         WHERE (@asgn_type = 'CAR') and
               (payheader.asgn_id = carrier.car_id) and
               (payheader.pyh_pyhnumber = @payheader OR
                  (payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
   ELSE
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         carrier.car_otherid,
         @dummy,
         carrier.car_address1,
         carrier.car_address2,
         carrier.cty_code,
         carrier.car_zip,
         carrier.car_phone1,
         carrier.car_name,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         carrier.car_name,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021
      FROM payheader, carrier
         WHERE    (@asgn_type = 'CAR') and
         (payheader.asgn_id = carrier.car_id) and
         (payheader.pyh_pyhnumber = @payheader OR
                  ( payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
END

IF @asgn_type = 'TPR'
BEGIN
   IF (SELECT tpr_payto
       FROM   thirdpartyprofile
       WHERE  tpr_id = @asgn_id) <> 'UNKNOWN'
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         payto.pto_altid,
         payto.pto_ssn,
         payto.pto_address1,
         payto.pto_address2,
         payto.pto_city,
         payto.pto_zip,
         payto.pto_phone1,
         payto.pto_lastfirst,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         thirdpartyprofile.tpr_name,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021
      FROM payheader LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id,
            thirdpartyprofile
         WHERE (@asgn_type = 'TPR') and
               (payheader.asgn_id = thirdpartyprofile.tpr_id) and
               (payheader.pyh_pyhnumber = @payheader OR
                  (payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
   ELSE
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         @varchar8,
         @dummy,
         thirdpartyprofile.tpr_address1,
         thirdpartyprofile.tpr_address2,
         thirdpartyprofile.tpr_city,
         thirdpartyprofile.tpr_zip,
         thirdpartyprofile.tpr_primaryphone,
         thirdpartyprofile.tpr_name,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         thirdpartyprofile.tpr_name,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number ,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021

      FROM payheader, thirdpartyprofile
         WHERE    (@asgn_type = 'TPR') and
         (payheader.asgn_id = thirdpartyprofile.tpr_id) and
         (payheader.pyh_pyhnumber = @payheader OR
                  ( payheader.pyh_payperiod = @paydate AND
                  payheader.asgn_type = @asgn_type AND
                  payheader.asgn_id = @asgn_id))
END

IF @asgn_type = 'PTO'
BEGIN

   SELECT payheader.pyh_paystatus,
      payheader.pyh_prorap,
      payheader.pyh_payperiod,
      payheader.pyh_payto,
      payheader.pyh_pyhnumber,
      payheader.asgn_type,
      payheader.asgn_id,
      payheader.pyh_totalcomp,
      payheader.pyh_totaldeduct,
      payheader.pyh_totalreimbrs,
      payto.pto_altid,
      payto.pto_ssn,
      payto.pto_address1,
      payto.pto_address2,
      payto.pto_city,
      payto.pto_zip,
      payto.pto_phone1,
      payto.pto_lastfirst,
      @dummy,
      @dummy,
      @dummy,
      @dummy,
      @varchar45,
      payheader.crd_cardnumber,
      0.00,
      payheader.pyh_issuedate,
      payheader.pyh_ref_type,
      payheader.pyh_ref_number,
      payheader.pyh_currency,
      payheader.pyh_days_athome,
      payheader.payee_invoice_number,     -- PTS 47021
      payheader.payee_invoice_date     -- PTS 47021
   FROM payheader LEFT OUTER JOIN payto on payheader.pyh_payto = payto.pto_id
   WHERE payheader.pyh_payto = @asgn_id and
         (payheader.pyh_pyhnumber = @payheader OR
            payheader.pyh_payperiod = @paydate )
END
-- 14742 JD allow retrieve just by payheader number.
If @asgn_type = 'UNK' and @payheader > 0
      SELECT payheader.pyh_paystatus,
         payheader.pyh_prorap,
         payheader.pyh_payperiod,
         payheader.pyh_payto,
         payheader.pyh_pyhnumber,
         payheader.asgn_type,
         payheader.asgn_id,
         payheader.pyh_totalcomp,
         payheader.pyh_totaldeduct,
         payheader.pyh_totalreimbrs,
         payto.pto_altid,
         payto.pto_ssn,
         payto.pto_address1,
         payto.pto_address2,
         payto.pto_city,
         payto.pto_zip,
         payto.pto_phone1,
         payto.pto_lastfirst,
         @dummy,
         @dummy,
         @dummy,
         @dummy,
         manpowerprofile.mpp_lastfirst,
         payheader.crd_cardnumber,
         0.00,
         payheader.pyh_issuedate,
         payheader.pyh_ref_type,
         payheader.pyh_ref_number,
         payheader.pyh_currency,
         payheader.pyh_days_athome,
         payheader.payee_invoice_number,     -- PTS 47021
         payheader.payee_invoice_date     -- PTS 47021
      FROM  payheader  LEFT OUTER JOIN  payto  ON  payheader.pyh_payto  = payto.pto_id
         LEFT OUTER JOIN  manpowerprofile  ON  payheader.asgn_id  = manpowerprofile.mpp_id
         WHERE    (payheader.pyh_pyhnumber = @payheader) --even if it matches on a tractor id the application has a computed expression to fix the name.



GO
GRANT EXECUTE ON  [dbo].[D_STLMNT_HDR_overloadpayto] TO [public]
GO

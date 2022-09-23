SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_non_conformance_sp_vt]
(
    @ordnum	varchar(12)
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Called by Non Conformance Window and report.

exec d_non_conformance_sp_vt '2sf392'

*/

BEGIN

    declare @shipper_bill_of_lading varchar(20)
    
    CREATE TABLE #temp(
            ord_hdrnumber int not null, 
            sf_sequence_number int not null, 
            trc_number char(8) null, 
            trc_terminal char(6) null, 
            mpp_firstname varchar(40) null,
            mpp_lastname varchar(40) null,
            mpp_id char(8) null,
            mpp_terminal char(6) null, 
            trl_number char(8) null, 
            trl_terminal char(6) null,
            cmp_id char(8) null, 
            sf_contacted_shipper char(20) null, 
            sf_shipper_contact_name char(20) null,
            sf_shipper_contact_date datetime null, 
            sf_contacted_consignee char(20) null,
            sf_consignee_contact_name char(20) null, 
            sf_consignee_contact_date datetime null,
            sf_supervisor char(6) null, 
            sft_cause_id int not null,
            sf_shipper_rescheduled_date datetime null, 
            sf_consignee_rescheduled_date datetime null, 
            sf_cause_description varchar(255) null, 
            sft_effect_id int not null, 
            sf_effect_description varchar(255) null, 
            sf_investigator char(20) null, 
            sf_corrective_action varchar(255) null, 
            sf_product_release char(1) null, 
            sf_entereddate datetime null, 
            sf_updatedby char(20) null, 
            sf_carrier_id varchar(8) null, 
            sf_incident_date datetime null,
            sf_incident_number char(15) null, 
            sf_results_of_follow_up varchar(255) null, 
            sf_name_of_qit_chairperson varchar(40) null, 
            sf_closure_date datetime null,
            sf_incident_location char(25) null, 
            sf_shipper_contact_format char(1) null,
            sf_consignee_contact_format char(1) null, 
            sf_dangerous_hazardous char(1) null,
            commodities varchar(100) null,
            ord_revtype1 varchar(6) null, 
            ord_subcompany varchar(8) null, 
            ord_origin_earliestdate datetime null, 
            ord_origin_latestdate datetime null,
            ord_dest_earliestdate datetime null, 
            ord_dest_latestdate datetime null,
            DriverAltId varchar(8) null,
            cause_desc varchar(255) null,
            effect_desc varchar(255) null,
            company_name varchar(30) null,
            company_city varchar(18) null,
            company_state char(2) null,
            shipper_name varchar(30) null,
            shipper_city varchar(18) null,
            shipper_state char(2) null,
            consignee_name varchar(30) null,
            consignee_city varchar(18) null,
            consignee_state char(2) null,
            ord_refnum varchar(20) null,
            ord_reftype varchar(6) null,
            sf_deviation_type varchar(6) null,
            sf_follow_up_required char(1) null, 
            sf_followed_up_date datetime null, 
            sf_followed_up char(1) null
            )
    
    select  @shipper_bill_of_lading = ref_number 
    FROM    referencenumber
    WHERE   ref_tablekey = convert(int, @ordnum)
            and ref_table='orderheader'
            and ref_type='REF'
            order by ref_sequence desc
    
    Insert into #temp
    SELECT sf.ord_hdrnumber, sf.sf_sequence_number, 
           sf.trc_number, sf.trc_terminal, mpp.mpp_firstname, 
           mpp.mpp_lastname, sf.mpp_id,
           sf.mpp_terminal, sf.trl_number, sf.trl_terminal,
           sf.cmp_id, 
           sf.sf_contacted_shipper, sf.sf_shipper_contact_name,
           sf.sf_shipper_contact_date, sf.sf_contacted_consignee,
           sf.sf_consignee_contact_name, sf.sf_consignee_contact_date,
           sf.sf_supervisor, sf.sft_cause_id,
           sf.sf_shipper_rescheduled_date, sf.sf_consignee_rescheduled_date, 
           sf.sf_cause_description, sf.sft_effect_id, 
           sf.sf_effect_description, sf.sf_investigator, 
           sf.sf_corrective_action, sf.sf_product_release, 
           sf.sf_entereddate, sf.sf_updatedby, 
           sf.sf_carrier_id, sf.sf_incident_date,
           sf.sf_incident_number,
           sf.sf_results_of_follow_up, sf.sf_name_of_qit_chairperson, 
           sf.sf_closure_date,
           sf.sf_incident_location, sf.sf_shipper_contact_format,
           sf.sf_consignee_contact_format, sf.sf_dangerous_hazardous,
           '                                                                ' as 'Commodities',
           oh.ord_revtype1, oh.ord_subcompany, 
           oh.ord_origin_earliestdate, oh.ord_origin_latestdate,
           oh.ord_dest_earliestdate, oh.ord_dest_latestdate,
           mpp_otherid as DriverAltId,
           '                                        ' as Cause_desc,
           '                                        ' as Effect_desc,
           sfco.cmp_name,  sfcocity.cty_name, sfcocity.cty_state, 
           shipco.cmp_name,  shipcity.cty_name, shipcity.cty_state, 
           consignco.cmp_name,  consigncity.cty_name, consigncity.cty_state,
           @shipper_bill_of_lading,
           oh.ord_reftype,
           sf.sf_deviation_type, 
           sf.sf_follow_up_required, 
           sf.sf_followed_up_date, 
           sf.sf_followed_up 
    FROM   orderheader oh
            INNER JOIN servicefailure sf
            ON oh.ord_hdrnumber = sf.ord_hdrnumber
            LEFT OUTER JOIN manpowerprofile mpp
            ON sf.mpp_id = mpp.mpp_id
            LEFT OUTER JOIN company shipco
            ON oh.ord_shipper = shipco.cmp_id
            LEFT OUTER JOIN city shipcity
            ON shipco.cmp_city = shipcity.cty_code
            LEFT OUTER JOIN company consignco
            ON oh.ord_consignee = consignco.cmp_id
            LEFT OUTER JOIN city consigncity
            ON consignco.cmp_city = consigncity.cty_code
            LEFT OUTER JOIN company sfco
            ON sf.cmp_id = sfco.cmp_id
            LEFT OUTER JOIN city sfcocity
            ON sfco.cmp_city = sfcocity.cty_code  
    WHERE oh.ord_hdrnumber = CONVERT(int, @ordnum) 
    
    select
    ord_hdrnumber, 
    sf_sequence_number, 
    trc_number, 
    trc_terminal, 
    mpp_firstname,
    mpp_lastname,
    mpp_id,
    mpp_terminal, 
    trl_number, 
    trl_terminal,
    cmp_id, 
    sf_contacted_shipper, 
    sf_shipper_contact_name,
    sf_shipper_contact_date, 
    sf_contacted_consignee,
    sf_consignee_contact_name, 
    sf_consignee_contact_date,
    sf_supervisor, 
    sft_cause_id,
    sf_shipper_rescheduled_date, 
    sf_consignee_rescheduled_date, 
    sf_cause_description, 
    sft_effect_id, 
    sf_effect_description, 
    sf_investigator, 
    sf_corrective_action, 
    sf_product_release, 
    sf_entereddate, 
    sf_updatedby, 
    sf_carrier_id, 
    sf_incident_date,
    sf_incident_number, 
    sf_results_of_follow_up, 
    sf_name_of_qit_chairperson, 
    sf_closure_date,
    sf_incident_location, 
    sf_shipper_contact_format,
    sf_consignee_contact_format, 
    sf_dangerous_hazardous,
    commodities,
    ord_revtype1, 
    ord_subcompany, 
    ord_origin_earliestdate, 
    ord_origin_latestdate,
    ord_dest_earliestdate, 
    ord_dest_latestdate,
    DriverAltId,
    cause_desc,
    effect_desc,
    company_name,
    company_city,
    company_state,
    shipper_name,
    shipper_city,
    shipper_state,
    consignee_name,
    consignee_city,
    consignee_state,
    ord_refnum,
    ord_reftype,
    sf_deviation_type, 
    sf_follow_up_required, 
    sf_followed_up_date, 
    sf_followed_up 
    from #temp
    
    drop table #temp

END
GO
GRANT EXECUTE ON  [dbo].[d_non_conformance_sp_vt] TO [public]
GO

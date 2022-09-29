CREATE TABLE [dbo].[carrier]
(
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_fedid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address1] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address2] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_code] [int] NULL,
[car_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_scac] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_contact] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_type1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_type2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_type3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_type4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_misc1] [varchar] (450) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_misc2] [varchar] (450) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_misc3] [varchar] (450) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_misc4] [varchar] (450) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_phone1] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_phone2] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_phone3] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_lastactivity] [datetime] NULL,
[car_actg_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_iccnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_contract] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_otherid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_usecashcard] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_board] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_updateddate] [datetime] NULL,
[car_createdate] [datetime] NULL,
[car_exp1_date] [datetime] NULL,
[car_exp2_date] [datetime] NULL,
[car_terminationdt] [datetime] NULL,
[car_email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_service_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_gp_class] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_carrier_car_gp_class] DEFAULT ('DEFAULT'),
[car_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_carrier_car_currency] DEFAULT ('UNK'),
[car_agent] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_carrier_car_agent] DEFAULT ('UNKNOWN'),
[car_trltype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_trltype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_trltype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_trltype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_ins_cargolimits] [int] NULL,
[car_ins_liabilitylimits] [int] NULL,
[car_ins_certificate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_ins_w9] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_ins_contract] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_exp1_enddate] [datetime] NULL,
[car_exp2_enddate] [datetime] NULL,
[car_204flag] [int] NULL CONSTRAINT [DF_car_204flag] DEFAULT ((0)),
[car_210flag] [int] NULL CONSTRAINT [DF_car_210flag] DEFAULT ((0)),
[car_214flag] [int] NULL CONSTRAINT [DF_car_214flag] DEFAULT ((0)),
[car_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_dotnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_rating] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_quickentry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_car_quickentry] DEFAULT ('N'),
[car_confirmprint] [tinyint] NULL,
[car_confirmfax] [tinyint] NULL,
[car_confirmemail] [tinyint] NULL,
[car_confirmpathname] [char] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_411_monitored] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__carrier__car_411__1C4873B5] DEFAULT ('N'),
[car_confirm_ir_id] [int] NULL,
[car_confirm_irk_id] [int] NULL,
[car_confirm_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_extequip_interval_warnlevel] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_extequip_interval_hours] [int] NULL,
[car_extequip_interval_maxcount] [int] NULL,
[car_fgt_pay_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_hazmat] [smallint] NULL,
[car_approval_dt] [datetime] NULL,
[car_sub_iccnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_eft_flag] [smallint] NULL,
[car_web_address] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_region_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_manager] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_tier_rating] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_tenderloadby] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_204validate] [int] NULL,
[car_CRMType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_loads_offered] [int] NULL,
[car_loads_responded_to] [int] NULL,
[car_loads_not_responded_to] [int] NULL,
[car_loads_awarded] [int] NULL,
[car_loads_on_time] [int] NULL,
[rowsec_rsrv_id] [int] NULL,
[dw_timestamp] [timestamp] NOT NULL,
[car_204tender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_204update] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_CarrierWatch_monitored] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_mt_type_loaded] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_mt_type_empty] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_204_cancel_new] [int] NULL,
[car_fuel_card_account_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_fuel_card_pay_type] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_RateBy] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_ctw_conv] [float] NULL,
[car_ctw_break] [float] NULL,
[car_wtc_conv] [float] NULL,
[car_ctw_weightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_ctw_volumeunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_relationship] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_report_url] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayScheduleId] [int] NULL,
[car_dispatch_compute_on_save] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_carrier_car_dispatch_compute_on_save] DEFAULT ('Y'),
[external_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_score] [int] NULL,
[car_preventrating] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_req_cin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_car_req_cin] DEFAULT ('N'),
[OriginDestinationOption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__carrier__INS_TIM__36F0DB0E] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_carrier] ON [dbo].[carrier] 
FOR DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 if exists 
  ( select * from event, deleted
     where deleted.car_id = event.evt_carrier ) 
   begin
-- Sybase Syntax
--   raiserror 99999 'Cannot delete carrier: Assigned to trips'
-- MSS Syntax
     raiserror('Cannot delete carrier: Assigned to trips',16,1)
     rollback transaction
   end
Else
Begin
    -- PTS 38486
	declare @car_id varchar(8),
                @tmwuser VARCHAR(255)
 
        exec gettmwuser @tmwuser output

	select @car_id = car_id from deleted

	delete from contact_profile where con_id = @car_id and con_asgn_type = 'CARRIER'

	delete from expiration where exp_id = @car_id and exp_idtype = 'CAR' -- PTS 39866

   IF (SELECT ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
         FROM generalinfo
        WHERE gi_name = 'CarrierFileAudit') = 'Y' AND @car_id IS NOT NULL
   BEGIN
      INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt, caf_update_by)
                            VALUES (@car_id, 'DELETED', GETDATE(), @tmwuser) 
   END

End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_carrier] on [dbo].[carrier] for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 * 
 * NAME:
 * dbo.it_carrier
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * Insert trigger for carrier table
 *
 * RETURNS:
 * NA
 * 
 * 
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 12/06/2005 ? PTS30236 JD Check if we need to create entries for activity table for carriers
 *
 **/



-- 30236 JD Check if we need to create entries for activity table for  carrier
declare @ll_prk int,
	@car_id	VARCHAR(8),
	@tmwuser VARCHAR(255)

If exists (select * from generalinfo where gi_name = 'AutoAssignResourceToRates' and upper(gi_string4) ='CAR'  )
BEGIN
	exec  @ll_prk = getsystemnumber 'PRDNUM',''
	Insert into payratekey
			(
			prk_number,
			asgn_type,
			asgn_id,
			prk_paybasis,
			prh_number,
			prk_name,
			prk_team,
			prk_car_trc_flag,
			prk_effective)
	Select @ll_prk,'CAR',car_id , 'LGH','ACTV!','CAR'+car_id+'ACTV!','N','BTH','19500101 00:00' from inserted
END

IF (SELECT ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
      FROM generalinfo
     WHERE gi_name = 'CarrierFileAudit') = 'Y'
BEGIN
   SELECT @car_id = car_id
     FROM inserted
   INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt, caf_update_by)
                         VALUES (@car_id, 'INSERTED', GETDATE(), @tmwuser)
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_carrier_setschedule]
ON [dbo].[carrier]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
/**
 * 
 * NAME: 
 * dbo.iut_carrier_setschedule
 *
 * TYPE: 
 * Trigger
 *
 * DESCRIPTION:
 * Sets the backoffice schedule ID on the asset
 * Note that Company, Division, Terminal and Fleet are not supported for Carrier
 *
 * RETURNS: 
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS: 
 * N/A
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 2014/10/28 | PTS 83554 | vjh	  - new trigger
 * 2015/04/08 | PTS 89156 | vjh   - Mindy's recommendations for how to test for update
 *
 **/

BEGIN
 
IF EXISTS
(
select d.car_id from deleted d inner join inserted i on d.car_id = i.car_id
where 
(
d.car_actg_type <> i.car_actg_type OR
d.car_type1 <> i.car_type1 OR
d.car_type2 <> i.car_type2 OR
d.car_type3 <> i.car_type3 OR
d.car_type4 <> i.car_type4
)
and d.PayScheduleId is not null
)
      update t 
      set PayScheduleId = NULL
      from carrier t 
	  inner join deleted d on t.car_id = d.car_id
	  inner join inserted i on t.car_id = i.car_id
      where 
      (
      d.car_actg_type <> i.car_actg_type OR
      d.car_type1 <> i.car_type1 OR
      d.car_type2 <> i.car_type2 OR
      d.car_type3 <> i.car_type3 OR
      d.car_type4 <> i.car_type4
      )
      and d.PayScheduleId is not null
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_carrier] ON [dbo].[carrier] 
FOR UPDATE
AS
DECLARE	@tmwuser	VARCHAR(255),
        @currentdate	DATETIME,
        @oldvalue	VARCHAR(100),
        @newvalue	VARCHAR(100),
        @car_id		VARCHAR(8),
	@oldcity	INTEGER,
        @newcity	INTEGER,
        @oldcitynm	VARCHAR(50),
        @newcitynm	VARCHAR(50)

EXEC gettmwuser @tmwuser OUTPUT


IF (SELECT ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
      FROM generalinfo
     WHERE gi_name = 'CarrierFileAudit') = 'Y'
BEGIN
   SET @currentdate = GETDATE()
   SELECT @car_id = inserted.car_id
     FROM inserted

   IF UPDATE(car_name)
   BEGIN
  /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_name, ' '),
             @newvalue = ISNULL(inserted.car_name, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'NAME', @oldvalue, @newvalue)
  */                                     
                                    
      INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'NAME', deleted.car_name, inserted.car_name 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_name,'') <> ISNULL (inserted.car_name, '')

   END 

   IF UPDATE(car_address1)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_address1, ' '),
             @newvalue = ISNULL(inserted.car_address1, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'ADDRESS1', @oldvalue, @newvalue)
  */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'ADDRESS1', deleted.car_address1, inserted.car_address1 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_address1,'')  <> ISNULL (inserted.car_address1, '')
   END 

   IF UPDATE(car_address2)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_address2, ' '),
             @newvalue = ISNULL(inserted.car_address2, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'ADDRESS2', @oldvalue, @newvalue)
                                       
 */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'ADDRESS2', deleted.car_address2, inserted.car_address2 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_address2,'')  <> ISNULL (inserted.car_address2,'')
   END

   IF UPDATE(cty_code)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldcity = ISNULL(deleted.cty_code, 0),
             @newcity = ISNULL(inserted.cty_code, 0)
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldcity <> @newcity
      BEGIN
         SELECT @oldcitynm = cty_nmstct
           FROM city
          WHERE cty_code = @oldcity
         SELECT @newcitynm = cty_nmstct
           FROM city
          WHERE cty_code = @newcity
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'CITY', @oldcitynm, @newcitynm)
      END
      
  */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'CITY', deleted.cty_code, inserted.cty_code 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.cty_code,0)  <> ISNULL (inserted.cty_code,0)
   END

   IF UPDATE(car_zip)
   BEGIN
/* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_zip, ' '),
             @newvalue = ISNULL(inserted.car_zip, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'ZIP CODE', @oldvalue, @newvalue)
   END 
         
  */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'ZIP CODE', deleted.car_zip, inserted.car_zip 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_zip,'')  <> ISNULL (inserted.car_zip, '')
   END


   IF UPDATE(car_scac)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_scac, ' '),
             @newvalue = ISNULL(inserted.car_scac, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'SCAC', @oldvalue, @newvalue)
   END
   
   */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'SCAC', deleted.car_scac, inserted.car_scac 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_scac, '')  <> ISNULL (inserted.car_scac, '')
   END

   IF UPDATE(car_phone1)
   BEGIN
/* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_phone1, ' '),
             @newvalue = ISNULL(inserted.car_phone1, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'MAIN PHONE', @oldvalue, @newvalue)
   END
    */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'MAIN PHONE', deleted.car_phone1, inserted.car_phone1 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_phone1, '')  <> ISNULL (inserted.car_phone1,'')
   END


   IF UPDATE(car_phone2)
   BEGIN
  /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates

      SELECT @oldvalue = ISNULL(deleted.car_phone2, ' '),
             @newvalue = ISNULL(inserted.car_phone2, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'SECONDARY PHONE', @oldvalue, @newvalue)
   END
    */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'SECONDARY PHONE', deleted.car_phone2, inserted.car_phone2 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_phone2, '')  <> ISNULL (inserted.car_phone2, '')
   END



   IF UPDATE(car_phone3)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_phone3, ' '),
             @newvalue = ISNULL(inserted.car_phone3, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'FAX', @oldvalue, @newvalue)
   END
       */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'FAX', deleted.car_phone3, inserted.car_phone3 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_phone3, '')  <> ISNULL (inserted.car_phone3, '')
   END


   IF UPDATE(car_contact)
   BEGIN
    /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_contact, ' '),
             @newvalue = ISNULL(inserted.car_contact, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'CONTACT', @oldvalue, @newvalue)
   END
       */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'CONTACT', deleted.car_contact, inserted.car_contact 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_contact,'')  <> ISNULL (inserted.car_contact, '')
   END


   IF UPDATE(car_fedid)
   BEGIN
    /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_fedid, ' '),
             @newvalue = ISNULL(inserted.car_fedid, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'FED ID', @oldvalue, @newvalue)
   END
        */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'FED ID', deleted.car_fedid, inserted.car_fedid 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_fedid,'')  <> ISNULL (inserted.car_fedid,'')
   END

   IF UPDATE(car_iccnum)
   BEGIN
     /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_iccnum, ' '),
             @newvalue = ISNULL(inserted.car_iccnum, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'MC NO', @oldvalue, @newvalue)
   END
        */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'MC NO', deleted.car_iccnum, inserted.car_iccnum 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_iccnum,'')  <> ISNULL (inserted.car_iccnum, '')
   END
   

   IF UPDATE(car_sub_iccnum)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_sub_iccnum, ' '),
             @newvalue = ISNULL(inserted.car_sub_iccnum, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'SUB MC NO', @oldvalue, @newvalue)
   END
       */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'SUB MC NO', deleted.car_sub_iccnum, inserted.car_sub_iccnum 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_sub_iccnum,'')  <> ISNULL (inserted.car_sub_iccnum, '')
   END

   IF UPDATE(car_dotnum)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_dotnum, ' '),
             @newvalue = ISNULL(inserted.car_dotnum, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'DOT NO', @oldvalue, @newvalue)
   END
     */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'DOT NO', deleted.car_dotnum, inserted.car_dotnum 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where  ISNULL (deleted.car_dotnum,'')  <>  ISNULL (inserted.car_dotnum, '')
   END


   IF UPDATE(car_email)
   BEGIN
      /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_email, ' '),
             @newvalue = ISNULL(inserted.car_email, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'EMAIL', @oldvalue, @newvalue)
   END
      */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'EMAIL', deleted.car_email, inserted.car_email 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where  ISNULL (deleted.car_email, '')  <>  ISNULL (inserted.car_email, '')
   END

   IF UPDATE(car_web_address)
   BEGIN
    /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_web_address, ' '),
             @newvalue = ISNULL(inserted.car_web_address, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'WEB ADDRESS', @oldvalue, @newvalue)
   END
    */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'WEB ADDRESS', deleted.car_web_address, inserted.car_web_address 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_web_address, '')  <> ISNULL (inserted.car_web_address, '')
   END


   IF UPDATE(car_currency)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_currency, ' '),
             @newvalue = ISNULL(inserted.car_currency, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'CURRENCY', @oldvalue, @newvalue)
   END
   */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'CURRENCY', deleted.car_currency, inserted.car_currency 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_currency,'')  <> ISNULL (inserted.car_currency, '')
   END

   IF UPDATE(car_tenderloadby)
   BEGIN
    /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_tenderloadby, ' '),
             @newvalue = ISNULL(inserted.car_tenderloadby, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'TENDER LOAD BY', @oldvalue, @newvalue)
   END
      */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'TENDER LOAD BY', deleted.car_tenderloadby, inserted.car_tenderloadby 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where ISNULL (deleted.car_tenderloadby,'')  <> ISNULL (inserted.car_tenderloadby,'')
   END

   IF UPDATE(car_approval_dt)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(RTRIM(CONVERT(varchar(10), deleted.car_approval_dt, 1) + ' ' +  
                                      CONVERT(VARCHAR(13), deleted.car_approval_dt, 114)), ' '),
             @newvalue = ISNULL(RTRIM(CONVERT(varchar(10), inserted.car_approval_dt, 1) + ' ' +  
                                      CONVERT(VARCHAR(13), inserted.car_approval_dt, 114)), ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'APPROVAL DATE', @oldvalue, @newvalue)
   END
    */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'APPROVAL DATE', deleted.car_approval_dt, inserted.car_approval_dt 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where  ISNULL(RTRIM(CONVERT(varchar(10), deleted.car_approval_dt, 1) + ' ' +  
                                      CONVERT(VARCHAR(13), deleted.car_approval_dt, 114)), ' ')  <> ISNULL(RTRIM(CONVERT(varchar(10), inserted.car_approval_dt, 1) + ' ' +  
                                      CONVERT(VARCHAR(13), inserted.car_approval_dt, 114)), ' ')
   END


   IF UPDATE(car_contract)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_contract, ' '),
             @newvalue = ISNULL(inserted.car_contract, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'CONTRACT', @oldvalue, @newvalue)
   END
      */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'CONTRACT', deleted.car_contract, inserted.car_contract 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_contract, '')  <> isnull (inserted.car_contract, '')
   END

   IF UPDATE(car_fgt_pay_terms)
   BEGIN
    /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(deleted.car_fgt_pay_terms, ' '),
             @newvalue = ISNULL(inserted.car_fgt_pay_terms, ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'FREIGHT TERMS', @oldvalue, @newvalue)
   END
      */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'FREIGHT TERMS', deleted.car_fgt_pay_terms, inserted.car_fgt_pay_terms 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_fgt_pay_terms, '')  <> isnull (inserted.car_fgt_pay_terms, '')
   END

   IF UPDATE(car_eft_flag)
   BEGIN
     /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(CAST(deleted.car_eft_flag AS VARCHAR(10)), ' '),
             @newvalue = ISNULL(CAST(inserted.car_eft_flag AS VARCHAR(10)), ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'EFT', @oldvalue, @newvalue)
   END
     */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'EFT', deleted.car_eft_flag, inserted.car_eft_flag 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_eft_flag,0)  <> isnull (inserted.car_eft_flag,0)
   END

   IF UPDATE(car_204flag)
   BEGIN
 /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(CAST(deleted.car_204flag AS VARCHAR(10)), ' '),
             @newvalue = ISNULL(CAST(inserted.car_204flag AS VARCHAR(10)), ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'EDI204', @oldvalue, @newvalue)
   END
     */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'EDI204', deleted.car_204flag, inserted.car_204flag 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_204flag, 0)  <> isnull (inserted.car_204flag, 0)
   END

   IF UPDATE(car_214flag)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(CAST(deleted.car_214flag AS VARCHAR(10)), ' '),
             @newvalue = ISNULL(CAST(inserted.car_214flag AS VARCHAR(10)), ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'EDI214', @oldvalue, @newvalue)
   END
    */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'EDI214', deleted.car_214flag, inserted.car_214flag 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_214flag, 0)  <> isnull (inserted.car_214flag, 0)
   END


   IF UPDATE(car_210flag)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(CAST(deleted.car_210flag AS VARCHAR(10)), ' '),
             @newvalue = ISNULL(CAST(inserted.car_210flag AS VARCHAR(10)), ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'EDI210', @oldvalue, @newvalue)
   END
     */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'EDI210', deleted.car_210flag, inserted.car_210flag 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_210flag, 0)  <> isnull (inserted.car_210flag, 0)
   END

   IF UPDATE(car_hazmat)
   BEGIN
   /* PTS 57381 remove read into variables so you can have triggers perform under multi row updates
      SELECT @oldvalue = ISNULL(CAST(deleted.car_hazmat AS VARCHAR(10)), ' '),
             @newvalue = ISNULL(CAST(inserted.car_hazmat AS VARCHAR(10)), ' ')
        FROM deleted, inserted
       WHERE deleted.car_id = inserted.car_id
      IF @oldvalue <> @newvalue
         INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,
                                       caf_update_by, caf_update_field,
                                       caf_original_value, caf_new_value)
                               VALUES (@car_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'HAZMAT', @oldvalue, @newvalue)
   END
    */
  INSERT INTO carrierfileaudit (car_id, caf_action, caf_update_dt,  
									caf_update_by, caf_update_field,  
									caf_original_value, caf_new_value)  
									select inserted.car_id, 'UPDATE', @currentdate,  
									@tmwuser, 'HAZMAT', deleted.car_hazmat, inserted.car_hazmat 
									from deleted inner join inserted on deleted.car_id = inserted.car_id
									where isnull(deleted.car_hazmat, 0)  <> isnull (inserted.car_hazmat, 0)
   END

END

GO
ALTER TABLE [dbo].[carrier] ADD CONSTRAINT [PK_carrier] PRIMARY KEY CLUSTERED ([car_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_car_branch] ON [dbo].[carrier] ([car_branch]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Carrier_CarDotNum] ON [dbo].[carrier] ([car_dotnum]) INCLUDE ([car_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Carrier_CarIccNum] ON [dbo].[carrier] ([car_iccnum]) INCLUDE ([car_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Carrier_timestamp] ON [dbo].[carrier] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [carrier_INS_TIMESTAMP] ON [dbo].[carrier] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_carrier_ptoid] ON [dbo].[carrier] ([pto_id], [car_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier] TO [public]
GO

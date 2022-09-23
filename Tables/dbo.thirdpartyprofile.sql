CREATE TABLE [dbo].[thirdpartyprofile]
(
[tpr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tpr_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_city] [int] NULL,
[tpr_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_primaryphone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_secondaryphone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_faxphone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_salesperson1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_salesperson1_pct] [numeric] (6, 4) NULL,
[tpr_salesperson2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_salesperson2_pct] [numeric] (6, 4) NULL,
[tpr_thirdpartytype1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_thirdpartytype2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_thirdpartytype3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_thirdpartytype4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_thirdpartytype5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_thirdpartytype6] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_artype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_invoicetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_createdate] [datetime] NULL,
[tpr_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_updateddate] [datetime] NULL,
[tpr_actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_service_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_gp_class] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_thirdpartyprofile_tpr_gp_class] DEFAULT ('DEFAULT'),
[tpr_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_thirdpartyprofile_tpr_currency] DEFAULT ('UNK'),
[tpr_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_thirdpartyprofile_tpr_branch] DEFAULT ('UNK'),
[tpr_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_hrs_week] [money] NULL,
[tpr_hrs_day] [money] NULL,
[tpr_hrs_dbl_time] [money] NULL,
[tpr_override_default_ot] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_otherid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_contractdate] [datetime] NULL,
[tpr_senioritydate] [datetime] NULL,
[rowsec_rsrv_id] [int] NULL,
[tpr_negprofitfee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_creditlimit] [money] NULL,
[dw_timestamp] [timestamp] NOT NULL,
[ThirdPartyType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayScheduleId] [int] NULL,
[OriginDestinationOption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_thirdpartyprofile] ON [dbo].[thirdpartyprofile] 
FOR DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
Begin
    --PTS 38486
	declare @tpr_id varchar(8)
	select @tpr_id = tpr_id from deleted

	delete from contact_profile where con_id = @tpr_id and con_asgn_type = 'TPR'
End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_thirdpartyprofile_setschedule]
ON [dbo].[thirdpartyprofile]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
/**
 * 
 * NAME: 
 * dbo.iut_thirdpartyprofile_setschedule
 *
 * TYPE: 
 * Trigger
 *
 * DESCRIPTION:
 * Sets the backoffice schedule ID on the asset
 * Note that Company, Division, Terminal and Fleet are not supported for ThirdPartyProfile
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
select d.tpr_id from deleted d inner join inserted i on d.tpr_id = i.tpr_id
where 
(
d.tpr_actg_type <> i.tpr_actg_type OR
d.ThirdPartyType1 <> i.ThirdPartyType1 OR
d.ThirdPartyType2 <> i.ThirdPartyType2 OR
d.ThirdPartyType3 <> i.ThirdPartyType3 OR
d.ThirdPartyType4 <> i.ThirdPartyType4
)
and d.PayScheduleId is not null
)
      update t 
      set PayScheduleId = NULL
      from thirdpartyprofile t 
	  inner join deleted d on t.tpr_id = d.tpr_id
	  inner join inserted i on t.tpr_id = i.tpr_id
      where 
      (
      d.tpr_actg_type <> i.tpr_actg_type OR
      d.ThirdPartyType1 <> i.ThirdPartyType1 OR
      d.ThirdPartyType2 <> i.ThirdPartyType2 OR
      d.ThirdPartyType3 <> i.ThirdPartyType3 OR
      d.ThirdPartyType4 <> i.ThirdPartyType4
      )
      and d.PayScheduleId is not null
END
GO
ALTER TABLE [dbo].[thirdpartyprofile] ADD CONSTRAINT [PK__thirdpartyprofil__395884C4] PRIMARY KEY CLUSTERED ([tpr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ThirdPartyProfile_timestamp] ON [dbo].[thirdpartyprofile] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tpr_cty] ON [dbo].[thirdpartyprofile] ([tpr_city]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_tpr_name] ON [dbo].[thirdpartyprofile] ([tpr_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[thirdpartyprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[thirdpartyprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[thirdpartyprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[thirdpartyprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[thirdpartyprofile] TO [public]
GO

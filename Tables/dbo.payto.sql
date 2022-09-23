CREATE TABLE [dbo].[payto]
(
[timestamp] [timestamp] NULL,
[pto_id] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pto_altid] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_fname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_mname] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_lname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pto_ssn] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_address1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_address2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_city] [int] NULL,
[pto_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_phone1] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_phone2] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_phone3] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_currency] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_type1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_type2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_type3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_type4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_company] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_division] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_terminal] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_lastfirst] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_updateddate] [datetime] NULL,
[pto_yrtodategross] [money] NULL,
[pto_socsecfedtax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_dirdeposit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_fleettrc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_startdate] [datetime] NULL,
[pto_terminatedate] [datetime] NULL,
[pto_createdate] [datetime] NULL,
[pto_companyname] [varchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_gp_class] [char] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_payto_pto_gp_class] DEFAULT ('DEFAULT'),
[pto_factorid] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_pto_factorid] DEFAULT ('UNKNOWN'),
[rowsec_rsrv_id] [int] NULL,
[pto_1099type] [int] NOT NULL CONSTRAINT [df_pto_1099type] DEFAULT ((0)),
[pto_max_advance_pertrip] [decimal] (7, 4) NOT NULL CONSTRAINT [DF__payto__pto_max_a__198442FF] DEFAULT ((0)),
[pto_max_advance_perday] [money] NOT NULL CONSTRAINT [DF__payto__pto_max_a__1A786738] DEFAULT ((0)),
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pto_arrears_start] [datetime] NOT NULL CONSTRAINT [DF__payto__pto_arrea__0A1B4163] DEFAULT ('01/01/1950 00:00'),
[pto_asset_maintenance_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_pto_asset_maintenance_type1] DEFAULT ('UNK'),
[pto_asset_maintenance_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_pto_asset_maintenance_type2] DEFAULT ('UNK'),
[pto_asset_maintenance_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_pto_asset_maintenance_type3] DEFAULT ('UNK'),
[pto_make_billto] [int] NULL CONSTRAINT [DF_payto_make_billto] DEFAULT ((0)),
[pto_stlByPayTo] [bit] NULL,
[PayScheduleId] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_payto_setschedule]
ON [dbo].[payto]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON
/**
 * 
 * NAME: 
 * dbo.iut_payto_setschedule
 *
 * TYPE: 
 * Trigger
 *
 * DESCRIPTION:
 * Sets the backoffice schedule ID on the asset
 * Note that actg_type is not supported for PayTo
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
select d.pto_id from deleted d inner join inserted i on d.pto_id = i.pto_id
where 
(
d.pto_company <> i.pto_company OR
d.pto_division <> i.pto_division OR
d.pto_terminal <> i.pto_terminal OR
d.pto_fleet <> i.pto_fleet OR
d.pto_type1 <> i.pto_type1 OR
d.pto_type2 <> i.pto_type2 OR
d.pto_type3 <> i.pto_type3 OR
d.pto_type4 <> i.pto_type4
)
and d.PayScheduleId is not null
)
      update t 
      set PayScheduleId = NULL
      from payto t 
	  inner join deleted d on t.pto_id = d.pto_id
	  inner join inserted i on t.pto_id = i.pto_id
      where 
      (
      d.pto_company <> i.pto_company OR
      d.pto_division <> i.pto_division OR
      d.pto_terminal <> i.pto_terminal OR
      d.pto_fleet <> i.pto_fleet OR
      d.pto_type1 <> i.pto_type1 OR
      d.pto_type2 <> i.pto_type2 OR
      d.pto_type3 <> i.pto_type3 OR
      d.pto_type4 <> i.pto_type4
      )
      and d.PayScheduleId is not null
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_pto_lastfirst] ON [dbo].[payto] 
FOR INSERT,  UPDATE  
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @f_name varchar(20), @l_name varchar(20), @m_name char(1), @lastfirst varchar(41)
                                

IF UPDATE (pto_fname)	
   OR UPDATE (pto_lname)	
   OR UPDATE (pto_mname)	

                           
BEGIN
   -- PTS 23799 -- BL (start)
--   SELECT @f_name = (SELECT pto_fname FROM inserted)			
--   SELECT @l_name = (SELECT pto_lname FROM inserted)			
--   SELECT @m_name = (SELECT pto_mname FROM inserted)			
   SELECT @f_name = (SELECT isnull(pto_fname, '') FROM inserted)			
   SELECT @l_name = (SELECT isnull(pto_lname, '') FROM inserted)			
   SELECT @m_name = (SELECT isnull(pto_mname, '') FROM inserted)
   -- PTS 23799 -- BL (end)

   IF @l_name > '' 
	SELECT @l_name = @l_name + ', '
   SELECT @lastfirst = @l_name + @f_name + ' ' + @m_name	
   UPDATE payto							
	SET pto_lastfirst = @lastfirst					
	FROM payto, inserted						
	WHERE payto.pto_id = inserted.pto_id				

END
    
                                          
GO
ALTER TABLE [dbo].[payto] ADD CONSTRAINT [PK_payto] PRIMARY KEY CLUSTERED ([pto_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pto_altid] ON [dbo].[payto] ([pto_altid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_payto_timestamp] ON [dbo].[payto] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payto] TO [public]
GO
GRANT INSERT ON  [dbo].[payto] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payto] TO [public]
GO
GRANT SELECT ON  [dbo].[payto] TO [public]
GO
GRANT UPDATE ON  [dbo].[payto] TO [public]
GO

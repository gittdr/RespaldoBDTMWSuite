CREATE TABLE [dbo].[recruitheader]
(
[rec_id] [int] NOT NULL IDENTITY(1, 1),
[rec_displayname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_firstname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_middlename] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_lastname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_address1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_address2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_city] [int] NULL,
[rec_enteredcity] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_county] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_homephone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_cellphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_website] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_ssn] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_cdlnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_recruiter] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_referral] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_creditstatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_division] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_reasoncall] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_truckyear] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_truckweight] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_monthlyincomeneed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_monthlytruckpmt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_currentgross] [int] NULL,
[rec_currentlyhauling] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_timeaway] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_createdon] [datetime] NULL,
[rec_createdby] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_updatedon] [datetime] NULL,
[rec_updatedby] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type8] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type9] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type10] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_datetype1] [datetime] NULL,
[rec_datetype2] [datetime] NULL,
[rec_datetype3] [datetime] NULL,
[rec_datetype4] [datetime] NULL,
[rec_datetype5] [datetime] NULL,
[rec_ref_mppid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_datetype6] [datetime] NULL,
[rec_datetype7] [datetime] NULL,
[rec_datetype8] [datetime] NULL,
[rec_type11] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_type12] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rec_csa_score] [int] NULL,
[rec_bonus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create TRIGGER [dbo].[ut_recruitheader]
ON [dbo].[recruitheader]
FOR update, insert AS

set nocount on

declare @rec_id int

-- Updates recruitheader table to concatinate last, first, and id for a display name.
if update(rec_lastname) or update(rec_firstname) 	
begin
	select @rec_id = min(rec_id)
	from inserted
	
	While @rec_id is not null	
	begin
		update recruitheader
		set rec_displayname = isnull(rec_lastname, '') + ', '+ isnull(rec_firstname, '') + ' (' + cast(rec_id as varchar(9)) + ')'
		where rec_id = @rec_id
		
		select @rec_id = min(rec_id)
		from inserted
		where rec_id > @rec_id
	end



	
end


set nocount off
GO
ALTER TABLE [dbo].[recruitheader] ADD CONSTRAINT [PK_recruitheader] PRIMARY KEY NONCLUSTERED ([rec_id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [recdisplay_ind] ON [dbo].[recruitheader] ([rec_displayname]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_recruitheader] ON [dbo].[recruitheader] ([rec_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[recruitheader] TO [public]
GO
GRANT INSERT ON  [dbo].[recruitheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[recruitheader] TO [public]
GO
GRANT SELECT ON  [dbo].[recruitheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[recruitheader] TO [public]
GO

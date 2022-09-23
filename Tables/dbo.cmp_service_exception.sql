CREATE TABLE [dbo].[cmp_service_exception]
(
[cse_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxn_sequence_number] [int] NULL,
[cse_variance] [int] NULL,
[cse_early_late] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cse_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[cse_reportable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cse_role] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cse_stop] [int] NULL,
[created_dt] [datetime] NULL CONSTRAINT [DF_CREATED_DT] DEFAULT (getdate()),
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_CREATED_BY] DEFAULT (suser_sname()),
[last_updateddt] [datetime] NULL CONSTRAINT [DF_LAST_UPDATEDT] DEFAULT (getdate()),
[last_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LAST_UPDATEDBY] DEFAULT (suser_sname()),
[cse_rpt_date] [datetime] NULL,
[cmp_var_setting] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_cmp_service_exception] ON [dbo].[cmp_service_exception]
	FOR Update
AS 
	-- PTS 61832 - DJM - Modified per Mindy's instructions.
    -- PTS 73762 - MTC - Made trigger ONLY an update trigger (removed Insert/Delete firing).
    --                   Changed cmp_service_exception table to have default values on updated date and time columns
	
	Declare 
		@updatecount	int,
		@inserted		int
		
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

	declare @date datetime
	select @date = getdate()

	
	select @updatecount = count(*) from deleted 
	
--	-- Set the Time and User id on new records
--	if @inserted > 0   
--		update cmp_service_exception    
--		set created_dt = @date,    
--			created_by = @tmwuser,    
--			last_updateddt = @date,    
--			last_updatedby = @tmwuser    
--		from cmp_service_exception e inner join inserted i on e.cse_id = i.cse_id
--	
--	
	-- Set the Time and User id on Updated records
   if @updatecount > 0
        update cmp_service_exception    
        set last_updateddt = @date,    
			last_updatedby = @tmwuser      
        from cmp_service_exception e inner join deleted d on e.cse_id = d.cse_id  


GO
ALTER TABLE [dbo].[cmp_service_exception] ADD CONSTRAINT [PK__cmp_service_exce__5465DD02] PRIMARY KEY CLUSTERED ([cse_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmp_service_exception] TO [public]
GO
GRANT INSERT ON  [dbo].[cmp_service_exception] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cmp_service_exception] TO [public]
GO
GRANT SELECT ON  [dbo].[cmp_service_exception] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmp_service_exception] TO [public]
GO

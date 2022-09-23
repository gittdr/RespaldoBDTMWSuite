CREATE TABLE [dbo].[company_service_variance]
(
[csv_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csv_pup_early] [int] NULL,
[csv_pup_late] [int] NULL,
[csv_del_early] [int] NULL,
[csv_del_late] [int] NULL,
[csv_billto_early] [int] NULL,
[csv_billto_late] [int] NULL,
[eff_date_start] [datetime] NULL,
[eff_date_end] [datetime] NULL,
[created_dt] [datetime] NULL,
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateddt] [datetime] NULL,
[last_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[iut_company_service_variance] ON [dbo].[company_service_variance]
	FOR Insert, Update, Delete
AS 
	
	Declare 
		@updatecount	int,
		@deletecount	int,
		@inserted		int
		
		DECLARE @tmwuser varchar (255)
		exec gettmwuser @tmwuser output


	
	select @deletecount = count(*) from deleted
	select @inserted = count(*) from inserted
	select @updatecount = (select count(*) from company_service_variance join Deleted on company_service_variance.csv_id = Deleted.csv_id)
	
	-- Set the Time and User id on new records
	if not exists (select 1 from company_service_variance join Deleted on company_service_variance.csv_id = Deleted.csv_id)
		update company_service_variance
		set created_dt = getdate(),
			created_by = @tmwuser,
			last_updateddt = getdate(),
			last_updatedby = @tmwuser
		where not exists (select 1 from company_service_variance join Deleted on company_service_variance.csv_id = Deleted.csv_id)
	
	
	-- Set the Time and User id on Updated records
	if exists (select 1 from company_service_variance join Deleted on company_service_variance.csv_id = Deleted.csv_id)
		update company_service_variance
		set last_updateddt = getdate(),
			last_updatedby = @tmwuser
		where exists (select 1 from company_service_variance join Deleted on company_service_variance.csv_id = Deleted.csv_id)


GO
ALTER TABLE [dbo].[company_service_variance] ADD CONSTRAINT [PK__company_service___51897057] PRIMARY KEY CLUSTERED ([csv_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_service_variance] TO [public]
GO
GRANT INSERT ON  [dbo].[company_service_variance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_service_variance] TO [public]
GO
GRANT SELECT ON  [dbo].[company_service_variance] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_service_variance] TO [public]
GO

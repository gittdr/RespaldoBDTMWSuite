CREATE TABLE [dbo].[sv_import_miles_by_state]
(
[imp_id] [int] NOT NULL IDENTITY(1, 1),
[dist_center] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unload_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[segment_start_date] [datetime] NULL,
[segment_end_date] [datetime] NULL,
[trip_date] [datetime] NULL,
[tractor_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trip_num] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odometer] [decimal] (19, 4) NULL,
[tot_distance] [decimal] (19, 4) NULL,
[laden_distance] [decimal] (19, 4) NULL,
[fuel_used] [decimal] (19, 4) NULL,
[toll] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [decimal] (19, 4) NULL,
[road] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_sv_import_miles_by_state_source_id] DEFAULT ('CADEC')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[dt_sv_import_miles_by_state] on [dbo].[sv_import_miles_by_state] for delete as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	insert into sv_import_miles_by_state_audit(
	audit_user,
	audit_dttm,
	audit_action,
	imp_id,
	dist_center,
	driver_id,
	unload_id,
	segment_start_date,
	segment_end_date,
	trip_date,
	tractor_id,
	trip_num,
	state_code,
	odometer,
	tot_distance,
	laden_distance,
	fuel_used,
	toll,
	weight,
	road,
	source_id	)
	(select 
	suser_sname(),
	getdate(),
	'D',
	imp_id,
	dist_center,
	driver_id,
	unload_id,
	segment_start_date,
	segment_end_date,
	trip_date,
	tractor_id,
	trip_num,
	state_code,
	odometer,
	tot_distance,
	laden_distance,
	fuel_used,
	toll,
	weight,
	road,
	source_id
	from deleted)


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_sv_import_miles_by_state] on [dbo].[sv_import_miles_by_state] for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
declare @imp_id int,
		@seg_start_date datetime,
		@dist_center varchar(3) ,
		@unload_id varchar(11),
		@driver_id varchar(10),
		@max_seg_start_date datetime
		
	if (select count(*) from inserted ) = 1
	begin
		select 	@imp_id = imp_id ,@dist_center = dist_center,@driver_id = driver_id , 
				@unload_id = unload_id , @seg_start_date = segment_start_date from inserted

		select 	@max_seg_start_date = max(segment_start_date) from sv_import_miles_by_state a
		where  	a.imp_id <> @imp_id and a.dist_center = @dist_center and a.driver_id = @driver_id and 
				a.unload_id = @unload_id and convert(varchar(8) , a.segment_start_date,112) = convert(varchar(8) , @seg_start_date,112)


		if @max_seg_start_date is not null
		begin
			select @max_seg_start_date = dateadd(ss,1,@max_seg_start_date)
			update sv_import_miles_by_state set segment_start_date = @max_seg_start_date where imp_id = @imp_id
		end


	end


	insert into sv_import_miles_by_state_audit(
	audit_user,
	audit_dttm,
	audit_action,
	imp_id,
	dist_center,
	driver_id,
	unload_id,
	segment_start_date,
	segment_end_date,
	trip_date,
	tractor_id,
	trip_num,
	state_code,
	odometer,
	tot_distance,
	laden_distance,
	fuel_used,
	toll,
	weight,
	road,
	source_id	)
	(select 
	suser_sname(),
	getdate(),
	'I',
	imp_id,
	dist_center,
	driver_id,
	unload_id,
	segment_start_date,
	segment_end_date,
	trip_date,
	tractor_id,
	trip_num,
	state_code,
	odometer,
	tot_distance,
	laden_distance,
	fuel_used,
	toll,
	weight,
	road,
	source_id
	from inserted)


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_sv_import_miles_by_state] on [dbo].[sv_import_miles_by_state] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	insert into sv_import_miles_by_state_audit(
	audit_user,
	audit_dttm,
	audit_action,
	imp_id,
	dist_center,
	driver_id,
	unload_id,
	segment_start_date,
	segment_end_date,
	trip_date,
	tractor_id,
	trip_num,
	state_code,
	odometer,
	tot_distance,
	laden_distance,
	fuel_used,
	toll,
	weight,
	road,
	source_id	)
	(select 
	suser_sname(),
	getdate(),
	'U',
	imp_id,
	dist_center,
	driver_id,
	unload_id,
	segment_start_date,
	segment_end_date,
	trip_date,
	tractor_id,
	trip_num,
	state_code,
	odometer,
	tot_distance,
	laden_distance,
	fuel_used,
	toll,
	weight,
	road,
	source_id
	from inserted)


GO
ALTER TABLE [dbo].[sv_import_miles_by_state] ADD CONSTRAINT [pk_sv_import_miles_by_state] PRIMARY KEY CLUSTERED ([imp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[sv_import_miles_by_state] TO [public]
GO
GRANT INSERT ON  [dbo].[sv_import_miles_by_state] TO [public]
GO
GRANT REFERENCES ON  [dbo].[sv_import_miles_by_state] TO [public]
GO
GRANT SELECT ON  [dbo].[sv_import_miles_by_state] TO [public]
GO
GRANT UPDATE ON  [dbo].[sv_import_miles_by_state] TO [public]
GO

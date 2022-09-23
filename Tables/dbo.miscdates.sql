CREATE TABLE [dbo].[miscdates]
(
[mdt_id] [int] NOT NULL IDENTITY(1, 1),
[mdt_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_tablekey] [int] NOT NULL,
[mdt_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdt_value] [datetime] NOT NULL,
[mdt_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mdt_updatedate] [datetime] NULL,
[mdt_timestamp] [timestamp] NULL,
[mdt_copiedfrom] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 

CREATE TRIGGER [dbo].[iudt_miscdates] ON [dbo].[miscdates]
FOR INSERT,UPDATE,DELETE 
AS


DELETE FROM miscdates
WHERE mdt_copiedfrom IN (select mdt_id from deleted)

--get next segment if there is one
declare @next_segment_stp_number int
declare @current_stp_number int
declare @current_stp_mfh_sequence int
declare @current_mov_number int
declare @current_lgh_number int

select	@current_stp_number = [mdt_tablekey], 
		@current_stp_mfh_sequence = stp_mfh_sequence,
		@current_mov_number = mov_number,
		@current_lgh_number = lgh_number
	from inserted join stops on [mdt_tablekey] = stp_number and [mdt_table] = 'stops' and [mdt_copiedfrom] is null
		
select top 1 @next_segment_stp_number = stp_number from stops where 
	@current_mov_number = mov_number
	and @current_lgh_number <> lgh_number
	and stp_mfh_sequence > @current_stp_mfh_sequence 
	order by stp_mfh_sequence



if IsNull(@next_segment_stp_number,0) > 0
	INSERT INTO [miscdates]
			   ([mdt_table]
			   ,[mdt_tablekey]
			   ,[mdt_type]
			   ,[mdt_value]
			   ,[mdt_updateby]
			   ,[mdt_updatedate]
			   ,[mdt_copiedfrom])
	SELECT		[mdt_table]
			   ,@next_segment_stp_number
			   ,[mdt_type]
			   ,[mdt_value]
			   ,[mdt_updateby]
			   ,GetDate()
			   ,[mdt_id]
			   from inserted 

GO
CREATE NONCLUSTERED INDEX [dk_miscdates] ON [dbo].[miscdates] ([mdt_table], [mdt_type], [mdt_tablekey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[miscdates] TO [public]
GO
GRANT INSERT ON  [dbo].[miscdates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[miscdates] TO [public]
GO
GRANT SELECT ON  [dbo].[miscdates] TO [public]
GO
GRANT UPDATE ON  [dbo].[miscdates] TO [public]
GO

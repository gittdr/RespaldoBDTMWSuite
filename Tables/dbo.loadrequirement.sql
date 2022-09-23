CREATE TABLE [dbo].[loadrequirement]
(
[ord_hdrnumber] [int] NOT NULL,
[lrq_sequence] [int] NOT NULL,
[lrq_equip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lrq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lrq_not] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lrq_manditory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL,
[lrq_quantity] [int] NULL,
[stp_number] [int] NULL,
[fgt_number] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_id_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[lrq_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[def_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrq_expire_date] [datetime] NULL,
[def_cmp_billto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadrequirement_id] [int] NOT NULL IDENTITY(1, 1),
[lrd_id] [int] NULL,
[lrq_field] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrq_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[dt_loadrequirement] on [dbo].[loadrequirement] for update as
SET NOCOUNT ON 
begin
	IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'Manhattan_Interface' AND LEFT(gi_string1,1) = 'Y')
	BEGIN
		INSERT INTO MANHATTAN_WorkQueue
			(mwq_type, mov_number, mwq_source)
			SELECT	'LOAD', d.mov_number, 'DT_LOADREQUIREMENT' 
			  FROM	deleted d
			 WHERE	NOT EXISTS(SELECT * FROM MANHATTAN_WorkQueue mwq WHERE mwq.mwq_type = 'LOAD' AND mwq.mov_number = d.mov_number)
	END
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[it_loadrequirement] on [dbo].[loadrequirement] for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
begin
	if exists (select * from inserted where lrq_default is null)
	begin
		raiserror ('Cannot insert load requirements with a default of null',16,1)
		rollback transaction
	end

	-- RE - PTS #60818 BEGIN
	IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'Manhattan_Interface' AND LEFT(gi_string1,1) = 'Y')
	BEGIN
		INSERT INTO MANHATTAN_WorkQueue
			(mwq_type, mov_number, mwq_source)
			SELECT	'LOAD', i.mov_number, 'IT_LOADREQUIREMENT' 
			  FROM	inserted i
			 WHERE	NOT EXISTS(SELECT * FROM MANHATTAN_WorkQueue mwq WHERE mwq.mwq_type = 'LOAD' AND mwq.mov_number = i.mov_number)
	END
	-- RE - PTS #60818 END
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_loadrequirement] on [dbo].[loadrequirement] for update as
SET NOCOUNT ON 
begin
	IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'Manhattan_Interface' AND LEFT(gi_string1,1) = 'Y')
	BEGIN
		INSERT INTO MANHATTAN_WorkQueue
			(mwq_type, mov_number, mwq_source)
			SELECT	'LOAD', i.mov_number, 'UT_LOADREQUIREMENT' 
			  FROM	inserted i
			 WHERE	NOT EXISTS(SELECT * FROM MANHATTAN_WorkQueue mwq WHERE mwq.mwq_type = 'LOAD' AND mwq.mov_number = i.mov_number)
	END
end

GO
ALTER TABLE [dbo].[loadrequirement] ADD CONSTRAINT [pk_loadrequirement] PRIMARY KEY NONCLUSTERED ([loadrequirement_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_lrq_loadrequirement_id] ON [dbo].[loadrequirement] ([loadrequirement_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lrq_type] ON [dbo].[loadrequirement] ([lrq_equip_type], [lrq_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_lrq_primary] ON [dbo].[loadrequirement] ([mov_number], [cmp_id], [def_id_type], [cmd_code]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [dk_ord_hdrnumber] ON [dbo].[loadrequirement] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[loadrequirement] TO [public]
GO
GRANT INSERT ON  [dbo].[loadrequirement] TO [public]
GO
GRANT REFERENCES ON  [dbo].[loadrequirement] TO [public]
GO
GRANT SELECT ON  [dbo].[loadrequirement] TO [public]
GO
GRANT UPDATE ON  [dbo].[loadrequirement] TO [public]
GO

CREATE TABLE [dbo].[EXTRA_INFO_DATA]
(
[EXTRA_ID] [int] NOT NULL,
[TAB_ID] [int] NOT NULL,
[COL_ID] [int] NOT NULL,
[COL_DATA] [varchar] (7665) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TABLE_KEY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[COL_ROW] [int] NOT NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[col_datetime] [datetime] NULL,
[col_number] [decimal] (12, 4) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[iut_extra_info_data] on [dbo].[EXTRA_INFO_DATA] for insert,update,delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
declare @table_key varchar(50), @rows int, @delrows int, @col_id int, @ord_field_num int,
 	@col_data varchar(30), @SQL nvarchar(250)

--this code will update all extra data fields on each save.
--	it will work for mass updates but only on the min order number
--	it will also work for deletes

select @rows = count(*) from inserted
select @delrows = count(*) from deleted
if @rows <= 1 and @delrows <=1
begin
	if @rows = 1
		select @table_key = table_key,
			@col_id  = col_id, 
			@col_data = left(isnull(col_data,''), 30) 
		from inserted
		where extra_id=7 and col_row=1  --only proceed for orders and 1st row
	else
		select @table_key = table_key,
			@col_id  = col_id, 
			@col_data = ''
		from deleted
		where extra_id=7 and col_row=1  --only proceed for orders and 1st row

	if @col_id is not null
		select 	@ord_field_num = ord_field_num
		from extra_info_cols
		where col_id = @col_id

	if @ord_field_num between 1 and 15 -- update orderheader
	begin
		select @col_data = replace(@col_data, '''', '''''')  --PTS 29206
		select @SQL = 'update orderheader set ord_extrainfo'+convert(varchar(2), @ord_field_num)+
			' = '''+@col_data+''' where ord_hdrnumber = '+convert(varchar(12),@table_key)+
			' and isnull(ord_extrainfo'+convert(varchar(2), @ord_field_num)+
			',''ZXZXZX'') <> '''+@col_data+''''

		exec sp_executesql @SQL
	end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_extradata_changelog] ON [dbo].[EXTRA_INFO_DATA] FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @updatecount	int,
	@delcount	int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255),
-- PTS 30623 -- BL (start)
        @curdate datetime
-- PTS 30623 -- BL (end)

exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted
-- PTS 30623 -- BL (start)
select @curdate = getdate()
-- PTS 30623 -- BL (end)

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update extra_info_data
	set last_updateby = @tmwuser,
-- PTS 30623 -- BL (start)
--		last_updatedate = getdate()
         last_updatedate = @curdate
-- PTS 30623 -- BL (end)
	from inserted
-- PTS 30623 -- BL (start)
--	where inserted.col_id = extra_info_data.col_id
--		and inserted.tab_id = extra_info_data.tab_id
--		and inserted.col_row = extra_info_data.col_id
--		and (isNull(extra_info_data.last_updateby,'') <> @tmwuser
--		OR isNull(extra_info_data.last_updatedate,'') <> getdate())
   where inserted.table_key = extra_info_data.table_key
     and inserted.extra_id = extra_info_data.extra_id
     and inserted.col_id = extra_info_data.col_id
     and inserted.col_row = extra_info_data.col_row
     and (isNull(extra_info_data.last_updateby,'') <> @tmwuser
         OR isNull(extra_info_data.last_updatedate,'') <> @curdate)
-- PTS 30623 -- BL (end)
	
GO
ALTER TABLE [dbo].[EXTRA_INFO_DATA] ADD CONSTRAINT [pk_extra_info_data] PRIMARY KEY CLUSTERED ([TABLE_KEY], [EXTRA_ID], [COL_ID], [COL_ROW]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [col_id] ON [dbo].[EXTRA_INFO_DATA] ([COL_ID], [TABLE_KEY], [COL_ROW]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EXTRA_INFO_DATA] TO [public]
GO
GRANT INSERT ON  [dbo].[EXTRA_INFO_DATA] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EXTRA_INFO_DATA] TO [public]
GO
GRANT SELECT ON  [dbo].[EXTRA_INFO_DATA] TO [public]
GO
GRANT UPDATE ON  [dbo].[EXTRA_INFO_DATA] TO [public]
GO

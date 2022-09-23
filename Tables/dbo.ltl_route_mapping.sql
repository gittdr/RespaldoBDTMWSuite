CREATE TABLE [dbo].[ltl_route_mapping]
(
[lrm_id] [int] NOT NULL IDENTITY(1, 1),
[lrm_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lrh_id] [int] NOT NULL,
[lrm_date] [datetime] NOT NULL,
[lrm_batch] [tinyint] NOT NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[dt_ltl_route_mapping] ON [dbo].[ltl_route_mapping]
FOR DELETE
AS
  Begin
  set nocount on
	delete ltl_route_detail
      from deleted d
     where ltl_route_detail.lrm_id = d.lrm_id
  end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_ltl_route_mapping] ON [dbo].[ltl_route_mapping]
FOR UPDATE
AS
  Begin
		set nocount on
		declare @ll_counter int
		select @ll_counter = min(lrm_id) from inserted
		while @ll_counter is not null
		begin
			if ((select isnull(mov_number,-1234567) from deleted where lrm_id = @ll_counter) = -1234567) and ((select isnull(mov_number,-1234567) from inserted where lrm_id = @ll_counter) <> -1234567)
			begin
				delete from ltl_route_mapping where lrm_id = @ll_counter
			end
			select @ll_counter = min(lrm_id) from inserted where lrm_id > @ll_counter
		end
  end
GO
ALTER TABLE [dbo].[ltl_route_mapping] ADD CONSTRAINT [pk_ltl_route_mapping_lrm_id] PRIMARY KEY CLUSTERED ([lrm_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lrl_route_mapping_lrh_id] ON [dbo].[ltl_route_mapping] ([lrh_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltl_route_mapping] ADD CONSTRAINT [fk_ltl_route_mapping_lrh_id] FOREIGN KEY ([lrh_id]) REFERENCES [dbo].[ltl_routeheader] ([lrh_id])
GO
GRANT DELETE ON  [dbo].[ltl_route_mapping] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_route_mapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltl_route_mapping] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_route_mapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_route_mapping] TO [public]
GO

CREATE TABLE [dbo].[inout_chart_det]
(
[chart_def_number] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[height] [float] NOT NULL,
[volume] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inout_chart_det] ADD CONSTRAINT [pk_inout_chart_det] PRIMARY KEY NONCLUSTERED ([chart_def_number], [height]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inout_chart_det] ADD CONSTRAINT [fk_inout_chart_det_to_def] FOREIGN KEY ([chart_def_number]) REFERENCES [dbo].[inout_chart_def] ([chart_def_number])
GO
GRANT DELETE ON  [dbo].[inout_chart_det] TO [public]
GO
GRANT INSERT ON  [dbo].[inout_chart_det] TO [public]
GO
GRANT REFERENCES ON  [dbo].[inout_chart_det] TO [public]
GO
GRANT SELECT ON  [dbo].[inout_chart_det] TO [public]
GO
GRANT UPDATE ON  [dbo].[inout_chart_det] TO [public]
GO

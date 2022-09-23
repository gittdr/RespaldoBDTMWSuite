CREATE TABLE [dbo].[inout_chart_def]
(
[chart_def_number] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[chart_def_type] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[chart_def_collar] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chart_def_note] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chart_def_height] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[chart_def_unit_of_measure] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inout_chart_def] ADD CONSTRAINT [PK__inout_ch__157198D3631E192B] PRIMARY KEY CLUSTERED ([chart_def_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inout_chart_def] TO [public]
GO
GRANT INSERT ON  [dbo].[inout_chart_def] TO [public]
GO
GRANT REFERENCES ON  [dbo].[inout_chart_def] TO [public]
GO
GRANT SELECT ON  [dbo].[inout_chart_def] TO [public]
GO
GRANT UPDATE ON  [dbo].[inout_chart_def] TO [public]
GO

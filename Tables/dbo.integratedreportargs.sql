CREATE TABLE [dbo].[integratedreportargs]
(
[ir_id] [int] NOT NULL,
[ira_sequence] [int] NOT NULL,
[ira_parameter] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ira_parameter_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ira_datatype] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ira_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ira_parameter_name_rpt] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreportargs] ADD CONSTRAINT [pk_integratedreportargs] PRIMARY KEY NONCLUSTERED ([ir_id], [ira_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreportargs] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreportargs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integratedreportargs] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreportargs] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreportargs] TO [public]
GO

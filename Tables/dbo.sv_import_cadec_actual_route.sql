CREATE TABLE [dbo].[sv_import_cadec_actual_route]
(
[Imp_batch] [int] NULL,
[Imp_id] [int] NOT NULL IDENTITY(1, 1),
[Dist_center] [smallint] NULL,
[Record_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Trip_date] [datetime] NULL,
[Trip_num] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Event_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field5] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field6] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field7] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field8] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field9] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field10] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field11] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field12] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field13] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field14] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field15] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field16] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field17] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field18] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_imp_batch] ON [dbo].[sv_import_cadec_actual_route] ([Imp_batch]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trip_num] ON [dbo].[sv_import_cadec_actual_route] ([Trip_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[sv_import_cadec_actual_route] TO [public]
GO
GRANT INSERT ON  [dbo].[sv_import_cadec_actual_route] TO [public]
GO
GRANT REFERENCES ON  [dbo].[sv_import_cadec_actual_route] TO [public]
GO
GRANT SELECT ON  [dbo].[sv_import_cadec_actual_route] TO [public]
GO
GRANT UPDATE ON  [dbo].[sv_import_cadec_actual_route] TO [public]
GO

CREATE TABLE [dbo].[ida_trip_pass_values]
(
[itp_column_order] [int] NOT NULL,
[itp_column_name] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[itp_column_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ida_trip_pass_values] ADD CONSTRAINT [PK__ida_trip__FAB11D19D68A516B] PRIMARY KEY CLUSTERED ([itp_column_order]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [itp_altkey] ON [dbo].[ida_trip_pass_values] ([itp_column_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ida_trip_pass_values] TO [public]
GO
GRANT INSERT ON  [dbo].[ida_trip_pass_values] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ida_trip_pass_values] TO [public]
GO
GRANT SELECT ON  [dbo].[ida_trip_pass_values] TO [public]
GO
GRANT UPDATE ON  [dbo].[ida_trip_pass_values] TO [public]
GO

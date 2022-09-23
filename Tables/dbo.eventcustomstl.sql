CREATE TABLE [dbo].[eventcustomstl]
(
[evt_number] [int] NOT NULL,
[evtcs_row_type] [int] NOT NULL,
[evtcs_trip_number] [int] NULL,
[evtcs_line_number] [int] NULL,
[evtcs_delivery_time] [decimal] (13, 4) NULL,
[evtcs_delivery_time_rounded] [decimal] (13, 4) NULL,
[sdd_id] [int] NULL,
[evtcs_created_date] [datetime] NOT NULL,
[evtcs_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evtcs_modified_date] [datetime] NOT NULL,
[evtcs_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eventcustomstl] ADD CONSTRAINT [PK_eventcustomstl] PRIMARY KEY NONCLUSTERED ([evt_number], [evtcs_row_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sdd_id] ON [dbo].[eventcustomstl] ([sdd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventcustomstl] TO [public]
GO
GRANT INSERT ON  [dbo].[eventcustomstl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[eventcustomstl] TO [public]
GO
GRANT SELECT ON  [dbo].[eventcustomstl] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventcustomstl] TO [public]
GO

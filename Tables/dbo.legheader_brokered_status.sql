CREATE TABLE [dbo].[legheader_brokered_status]
(
[lgh_number] [int] NOT NULL,
[status_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updateddate] [datetime] NOT NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legheader_brokered_status] ADD CONSTRAINT [PK__legheade__09F0C5993C1B957D] PRIMARY KEY CLUSTERED ([lgh_number], [updateddate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader_brokered_status] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader_brokered_status] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legheader_brokered_status] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader_brokered_status] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader_brokered_status] TO [public]
GO

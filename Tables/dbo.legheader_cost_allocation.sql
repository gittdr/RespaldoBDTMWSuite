CREATE TABLE [dbo].[legheader_cost_allocation]
(
[lgh_number] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[lca_linehaul] [money] NULL,
[lca_accessorial] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legheader_cost_allocation] ADD CONSTRAINT [PK__legheader_cost_a__7B34C609] PRIMARY KEY CLUSTERED ([lgh_number], [ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader_cost_allocation] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader_cost_allocation] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader_cost_allocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader_cost_allocation] TO [public]
GO

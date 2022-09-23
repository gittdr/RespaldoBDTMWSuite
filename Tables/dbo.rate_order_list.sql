CREATE TABLE [dbo].[rate_order_list]
(
[rol_tar_number] [int] NOT NULL,
[rol_ord_hdrnumber] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rate_order_list] ADD CONSTRAINT [pk_rateorder] PRIMARY KEY CLUSTERED ([rol_tar_number], [rol_ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rate_order_list] TO [public]
GO
GRANT INSERT ON  [dbo].[rate_order_list] TO [public]
GO
GRANT REFERENCES ON  [dbo].[rate_order_list] TO [public]
GO
GRANT SELECT ON  [dbo].[rate_order_list] TO [public]
GO
GRANT UPDATE ON  [dbo].[rate_order_list] TO [public]
GO

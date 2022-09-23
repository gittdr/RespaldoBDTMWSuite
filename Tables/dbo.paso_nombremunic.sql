CREATE TABLE [dbo].[paso_nombremunic]
(
[consecutivo] [numeric] (10, 0) NOT NULL,
[id_municipio] [numeric] (10, 0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paso_nombremunic] ADD CONSTRAINT [pk_municnombre] PRIMARY KEY NONCLUSTERED ([consecutivo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paso_nombremunic] TO [public]
GO
GRANT INSERT ON  [dbo].[paso_nombremunic] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paso_nombremunic] TO [public]
GO
GRANT SELECT ON  [dbo].[paso_nombremunic] TO [public]
GO
GRANT UPDATE ON  [dbo].[paso_nombremunic] TO [public]
GO

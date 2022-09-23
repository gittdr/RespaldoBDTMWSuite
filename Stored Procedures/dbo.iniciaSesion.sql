SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec iniciaSesion 'NADD'

create PROCEDURE [dbo].[iniciaSesion] (@user varchar(20))

AS
BEGIN
	declare @actual datetime
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select @actual = (select HoraIngreso from sesionVales where idUsuario = @user)

	if @actual = ''
		begin
			insert into sesionVales (idUsuario,HoraIngreso) values (@user,getdate())
		end
	else
		begin
			delete sesionVales where idUsuario = @user
			insert into sesionVales (idUsuario,HoraIngreso) values (@user,getdate())
		end
END
GO

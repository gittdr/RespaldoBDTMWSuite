SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE    Procedure [dbo].[sp_TTSTMWReplaceSQLInRow] (@tmwsqlforrow as varchar(8000),@tokenactivateflag char(1),@tokendeactivateflag char(1),@tmwobjectsql as varchar(8000) OUTPUT)

As

	If @tmwsqlforrow Like '%CREATE%' and (@tmwsqlforrow Like '%View%' or @tmwsqlforrow Like '%Proc%' or @tmwsqlforrow Like '%Procedure%')
	Begin
		Set @tmwobjectsql = @tmwobjectsql + Replace(@tmwsqlforrow,'Create','Alter')
	End
	Else If  @tokenactivateflag = 'T'
	Begin
		Set @tmwobjectsql = @tmwobjectsql + Replace(Replace(@tmwsqlforrow,'"',''''),'--','')
	End
	Else If @tokendeactivateflag = 'T'and Left(LTrim(@tmwsqlforrow),2) <> '--'
	Begin
		Set @tmwobjectsql = @tmwobjectsql + '--' + Replace(@tmwsqlforrow,'"','''')
	End
	Else
	Begin
		Set @tmwobjectsql = @tmwobjectsql + Replace(@tmwsqlforrow,'"','''')
	End	







GO

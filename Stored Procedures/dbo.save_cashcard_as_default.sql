SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--	Modified Date	By	Comment 							
--	-------------	---	-------						
--	5/11/2005		JZ	Created

CREATE PROCEDURE [dbo].[save_cashcard_as_default] 
	@crd_cardnumber varchar(20),
	@crd_accountid varchar(10),
	@crd_customerid varchar(10)
AS

--check if the row already exists in the default cashcard table
if exists (select * from cashcarddef where crddef_cardnumber=@crd_cardnumber 
	and crddef_accountid=@crd_accountid and crddef_customerid=@crd_customerid)
begin	--exist, delete the row
	delete cashcarddef where crddef_cardnumber=@crd_cardnumber 
		and crddef_accountid=@crd_accountid and crddef_customerid=@crd_customerid
end

insert into cashcarddef
	(
		crddef_cashlimit
		, crddef_cashrenewdaily
		, crddef_cashrenewsun
		, crddef_cashrenewmon
		, crddef_cashrenewtue
		, crddef_cashrenewwed
		, crddef_cashrenewthu
		, crddef_cashrenewfri
		, crddef_cashrenewsat
		, crddef_cashrenewtrip
		, crddef_purchaselimit
		, crddef_purchrenewdaily
		, crddef_purchrenewsun
		, crddef_purchrenewmon
		, crddef_purchrenewtue
		, crddef_purchrenewwed
		, crddef_purchrenewthu
		, crddef_purchrenewfri
		, crddef_purchrenewsat
		, crddef_purchrenewtrip
		, crddef_cardnumber
		, crddef_accountid
		, crddef_customerid
	)
	select 
			crd_cashlimit
			, crd_cashrenewdaily
			, crd_cashrenewsun
			, crd_cashrenewmon
			, crd_cashrenewtue
			, crd_cashrenewwed
			, crd_cashrenewthu
			, crd_cashrenewfri
			, crd_cashrenewsat
			, crd_cashrenewtrip
			, crd_purchaselimit
			, crd_purchrenewdaily
			, crd_purchrenewsun
			, crd_purchrenewmon
			, crd_purchrenewtue
			, crd_purchrenewwed
			, crd_purchrenewthu
			, crd_purchrenewfri
			, crd_purchrenewsat
			, crd_purchrenewtrip
			, crd_cardnumber
			, crd_accountid
			, crd_customerid
		from cashcard where crd_cardnumber=@crd_cardnumber 
		and crd_accountid=@crd_accountid and crd_customerid=@crd_customerid

return
GO
GRANT EXECUTE ON  [dbo].[save_cashcard_as_default] TO [public]
GO

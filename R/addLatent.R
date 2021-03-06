# addLatent.R
# copyright 2015-2016, openreliability.org
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

addLatent<-function(DF, at, mttf, mttr=NULL, pzero="repair", inspect=NULL, display_under=NULL, tag="", name="",name2="", description="")  {

	tp<-2

	info<-test.basic(DF, at,  display_under, tag)
	thisID<-info[1]
	parent<-info[2]
	gp<-info[3]
	condition<-info[4]

	if(any(DF$Type==5)) {
		stop("repairable system event event called for in non-repairable model")
	}

	if(is.null(mttf))  {stop("latent component must have mttf")}
	if(is.null(mttr)) { mttr<- (-1)}

	if(is.null(inspect))  {stop("latent component must have inspection entry")}

	if(is.null(pzero)) {pzero<- (-1)}
	if(is.character(inspect))  {
		if(exists("inspect")) {
			Tao<-eval((parse(text=inspect)))
		}else{
			stop("inspection interval object does not exist")
		}
	}else{
		Tao=inspect
	}

	## default Pzero handling
	if(pzero=="repair")  {
		if(!mttr>0)  {stop("mttr required for pzero calculation")}
		pzero=mttr/(mttf+mttr)
	}

	## fractional downtime method
	pf<-1-1/((1/mttf)*Tao)*(1-exp(-(1/mttf)*Tao))
	if(is.numeric(pzero))  {
		if(pzero>=0 && pzero<1) {
			pf<- 1-(1-pf)*(1-pzero)
		}else{ stop("pzero entry must be zero to one")}
	}

	gp<-at
	if(length(display_under)!=0)  {
		if(DF$Type[parent]!=10) {stop("Component stacking only permitted under OR gate")}
		if(DF$CParent[display_under]!=at) {stop("Must stack at component under same parent")}
		if(length(which(DF$GParent==display_under))>0 )  {
			stop("display under connection not available")
		}else{
			gp<-display_under
		}
	}

	Dfrow<-data.frame(
		ID=	thisID	,
		GParent=	gp	,
		CParent=	at	,
		Level=	DF$Level[parent]+1	,
		Type=	tp	,
		CFR=	1/mttf	,
		PBF=	pf	,
		CRT=	mttr	,
		MOE=	0	,
		Condition=	condition,
		Cond_Code=	0,
		EType=	0	,		
		P1=	pzero	,
		P2=	Tao	,
		Tag_Obj=	tag	,
		Name=	name	,
		Name2=	name2	,
		Description=	description	,
		UType=	0	,
		UP1=	-1	,
		UP2=	-1	
	)


	DF<-rbind(DF, Dfrow)
	DF
}

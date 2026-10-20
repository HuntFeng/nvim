return {
	article = [[
\documentclass{article}
\usepackage{amssymb, amsmath, amsthm}
\usepackage{physics}
\usepackage{float, subcaption, graphicx}
\usepackage{hyperref}

\title{$1}
\author{Hunt Feng\inst{1}}
\date{\today}

\begin{document}
%%%%%%%%%%%%%%%%%%%%
% title and TOC
%%%%%%%%%%%%%%%%%%%%
\maketitle
\tableofcontents

%%%%%%%%%%%%%%%%%%%%
% contents
%%%%%%%%%%%%%%%%%%%%
$2
%%%%%%%%%%%%%%%%%%%%
% references
%%%%%%%%%%%%%%%%%%%%
\newpage
\bibliographystyle{abbrv}
\bibliography{references}
\end{document}]],
	beamer = [[
\documentclass{beamer}
\usetheme{Madrid}
\colorlet{beamer@blendedblue}{green!40!black}
\setbeamertemplate{caption}[numbered]
\usepackage{amssymb, amsmath, amsthm}
\usepackage{physics}
\usepackage{float, subcaption, graphicx}
\usepackage{hyperref}

\title{$1}
\author{Hunt Feng\inst{1}}
\institute[Usask]
{
	\inst{1}%
	Faculty of Physics And Engineering Physics\\
	University of Saskatchewan
}
\date{\today}

%%%%%%%%%%%%%%%%%%%%
% define section page
%%%%%%%%%%%%%%%%%%%%
\AtBeginSection[]
{
	\begin{frame}{Outline of Presentation}
		\tableofcontents[currentsection]
	\end{frame}
}

\begin{document}
%%%%%%%%%%%%%%%%%%%%
% title and TOC
%%%%%%%%%%%%%%%%%%%%
\maketitle
\begin{frame}{Outline of Presentation}
	\tableofcontents
\end{frame}

%%%%%%%%%%%%%%%%%%%%
% contents
%%%%%%%%%%%%%%%%%%%%
$2
%%%%%%%%%%%%%%%%%%%%
% references
%%%%%%%%%%%%%%%%%%%%
\newpage
\begin{frame}[allowframebreaks]
	\bibliographystyle{abbrv}
	\bibliography{references}
\end{frame}
\end{document}]],
	frac = [[
\frac{$1}{$2}]],
	cite = [[
\cite{$1}]],
	leftp = [[
\left($1\right)]],
	leftb = [=[
\left[$1\right]]=],
	ref = [[
\ref{$1}]],
	refchap = [[
Chap.~\ref{chap:$1}]],
	refsec = [[
Sec.~\ref{sec:$1}]],
	refeq = [[
Eq.~(\ref{eq:$1})]],
	reffig = [[
Fig.~\ref{fig:$1}]],
	reftable = [[
Table.~\ref{table:$1}]],
	frame = [[
\begin{frame}{$1}
$2
\end{frame}]],
	equation = [[
\begin{equation}
$2
	\label{eq:$1}
\end{equation}]],
	figure = [[
\begin{figure}[htbp!]
	\centering
	\includegraphics[width=0.7\textwidth]{figures/$1}
	\caption{$2}
	\label{fig:$3}
\end{figure}]],
	table = [[
\begin{table}[htbp!]
	\centering
	\begin{tabular}{|c|c|}
		\hline
		  & \
		\hline
	\end{tabular}
	\caption{$1}
	\label{table:$2}
\end{table}]],
	enumerate = [[
\begin{enumerate}
	\item $1
\end{enumerate}]],
	lstlisting = [[
\begin{lstlisting}[language=$1] \label{lst:$3}
$2
\end{lstlisting}]],
}

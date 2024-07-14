declare module '*.module.css' {
	const classes: { [key: string]: string };
	export default classes;
}

declare module '*.png' {
	const value: any;
	export default value;
}